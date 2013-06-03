require 'openurl'
require 'httparty'

class Order < ActiveRecord::Base
  include HTTParty

  attr_accessible :atitle, :aufirst, :aulast, :callback_url, :date,
    :delivered_at, :doi, :eissn, :email, :epage, :isbn, :issn, :issue, :pages,
    :spage, :title, :volume

  has_many :order_requests, :dependent => :destroy

  validates :email, :presence => true
  validates :callback_url, :presence => true

  scope :recent, :limit => 10, :order => 'created_at DESC'
  scope :recent_delivered, where("delivered_at <> ''").limit(10).order('delivered_at DESC')

  def self.create_from_param(params)
    # Convert param to openurl data

    self.transaction do
      begin
        # Fix errors in the current open_url
        params[:open_url].gsub 'rft.year=', 'rft.date='
        params[:open_url].gsub 'rft.doi=', 'rft_id=info:/doi'

        # Convert string into OpenURL context object.
        data = OpenURL::ContextObject.new_from_kev (params[:open_url])

        # See if we can find a doi identifier
        doi = ""
        id = data.referent.identifier
        doi = $1 if /^info:doi\/(.+)/.match id

        # Make aulast, aufirst if not present in data
        aufirst = data.referent.aufirst
        aulast = data.referent.aulast
        if !aufirst and !aulast
          if /^([^,]*), (.+)/.match data.referent.au
            aulast = $1
            aufirst = $2
          else
            aulast = data.referent.au
          end
        end

        @order = Order.new do |o|
          o.aufirst = aufirst
          o.aulast = aulast
          o.title = data.referent.jtitle
          o.atitle = data.referent.atitle
          o.isbn = data.referent.isbn
          o.issn = data.referent.issn
          o.eissn = data.referent.eissn
          o.date = data.referent.date
          o.epage = data.referent.epage
          o.pages = data.referent.pages
          o.issue = data.referent.issue
          o.spage = data.referent.spage
          o.volume = data.referent.volume
          o.doi = doi
          o.callback_url = params[:callback_url]
          o.email = params[:email]
          o.save or raise "Order not valid"
        end

        system = params[:supplier]
        external_sys = ExternalSystem.find_by_code(system)
        raise "Unknown external system" unless(external_sys)
        @request = OrderRequest.new
        @request.order = @order
        @request.order_status = OrderStatus.find_by_code('new')
        @request.external_system = external_sys

        # Return error if we can't validate and save the record
        logger.info @request.inspect
        @request.valid? or raise "Request not valid"
        @request.save

        # Execute request
        @order.send("request_from_"+system)

      rescue StandardError => e
        logger.debug params[:callback_url] + ": " + e.message
        @order = nil
        raise ActiveRecord::Rollback
      end
    end

    @order
  end

  def config
    Rails.application.config
  end

  def current_request
    order_requests.current.first
  end

  def request(system, external_id)
    OrderRequest.where(:order_id => id,
      :external_system_id => ExternalSystem.find_by_code(system),
      :external_id => external_id).first
  end

  def mark_delivery
    delivered_at = Time.new
    do_callback('deliver')
  end

  def do_callback(response_code)
    response = HTTParty.get(callback_url +
      (/\?/.match(callback_url) ? '&' : '?') +
      "status=#{response_code}")
    if !response.success?
      # Put the request on the delay queue.
    end
  end

end
