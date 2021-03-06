require 'openurl'
require 'httparty'
require 'time'

class JoinAddressLines
  def initialize(address)
    @address = address || {}
  end

  def call
    [@address['line1'], @address['line2'], @address['line3'],
     @address['line4'], @address['line5'], @address['line6'],
     @address['zipcode'], @address['cityname'], @address['country']]
    .reject { |v| v.blank? }.join("\n")
  end
end

class LookupFailure < StandardError
end

class Order < ActiveRecord::Base
  attr_accessible :atitle, :aufirst, :aulast, :callback_url, :date,
    :delivered_at, :doi, :eissn, :email, :epage, :isbn, :issn, :issue, :pages,
    :spage, :title, :volume, :customer_order_number, :requester_first_name, :requester_last_name, :requester_email, :requester_address, :requester_findit_user_type

  has_many :order_requests, :dependent => :destroy
  belongs_to :institute
  belongs_to :user_type

  validates :email, :presence => true
  validates :callback_url, :presence => true

  scope :recent, :limit => 10, :order => 'created_at DESC'
  scope :recent_delivered, where("delivered_at IS NOT NULL").limit(10).order('delivered_at DESC')

  def self.create_from_param(params, controller)
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
        aufirst = nil
        aulast = nil
        aufirst = data.referent.aufirst if data.referent.respond_to?("aufirst")
        aulast = data.referent.aulast if data.referent.respond_to?("aulast")
        if !aufirst and !aulast
          if data.referent.respond_to?("au")
            if /^([^,]*), (.+)/.match data.referent.au
              aulast = $1
              aufirst = $2
            else
              aulast = data.referent.au
            end
          end
        end

        @order = Order.new do |o|
          o.aufirst = aufirst
          o.aulast = aulast
          o.title = truncate(data.referent.jtitle)
          o.atitle = truncate(data.referent.atitle)
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
          o.customer_order_number = params[:dibs_order_id]
          o.email = params[:email]
          o.user(params[:user_id], params[:findit_user_type])
          o.save or raise "Order not valid"
          o.path_controller = controller
          if params[:timecap_base].blank?
            o.timecap_date = Time.now().round(0)
          else
            o.timecap_date = Time.iso8601(params[:timecap_base])
          end
        end

        system = params[:supplier]
        external_sys = ExternalSystem.find_by_code(system)
        raise "Unknown external system" unless(external_sys)
        @request = OrderRequest.new
        @request.order = @order
        @request.order_status = OrderStatus.find_by_code('new')
        @request.external_system = external_sys

        # Return error if we can't validate and save the record
        @request.valid? or raise "Request not valid"
        @request.save

        # Execute request
        @order.send("request_from_"+system)

      rescue LookupFailure => e
        logger.info params[:callback_url] + ": " + e.message
        @order = nil
        raise ActiveRecord::Rollback
      rescue StandardError => e
        logger.warn params[:callback_url] + ": " + e.message +
          "\n\tBacktrace:\n\t#{e.backtrace.join("\n\t")}"
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

  def request(system, external_number)
    OrderRequest.where(:order_id => id,
      :external_system_id => ExternalSystem.find_by_code(system),
      :external_number => external_number).first
  end

  def system_request(system)
    OrderRequest.where(:order_id => id,
      :external_system_id => ExternalSystem.find_by_code(system)).first
  end

  def mark_physical_delivery
    self.delivered_at = Time.now
    do_callback('physically_deliver', {})
    save!
  end

  def mark_delivery(url)
    raise ArgumentError.new("Missing url") unless url
    self.delivered_at = Time.now
    do_callback('deliver', :url => url)
    save!
  end

  def do_callback(response_code, args = {})
    begin
      response = HTTParty.get(callback_url +
        (/\?/.match(callback_url) ? '&' : '?') +
        callback_param(response_code, args))
      if !response.success?
        raise StandardError, "Callback request unsuccessfull"
      end
    rescue StandardError => e
      raise StandardError, "Callback failed for #{callback_url} - #{e.message}"
    end
    true
  end

  def path_controller=(value)
    @path_controller = value
  end

  def user(value, findit_user_type = "")
    @user = Hash.new
    return if value.blank?
    @user = Riyosha.find(value)
    logger.info "User #{@user.inspect}"
    self.user_type = UserType.find_or_create_by_code(:code => @user['user_type'])
    if @user['dtu']
      raise LookupFailure if @user['dtu']['reason'] == 'lookup_failed'
      code = Institute.find_or_create_by_code(:code =>
        @user['dtu']['org_units'].join(','))
      self.institute = code
    end

    self.requester_email = @user['email']
    self.requester_address = JoinAddressLines.new(@user['address']).call
    self.requester_first_name = @user['first_name']
    self.requester_last_name = @user['last_name']
    self.requester_findit_user_type = findit_user_type

  end

  def reason=(text)
    @reason = text
  end

  def callback_param(response_code, args)
    { :status => response_code,
      :reason => @reason
    }.merge(args)
     .reject {|k,v| v.blank?}
     .collect {|k,v| "#{k}=#{URI.encode_www_form_component v}"}
     .join '&'
  end

  def name
    customer_order_number || atitle
  end

  def timecap_date=(date)
    @timecap_date = date
    logger.info "Timecap set #{@timecap_date}"
  end

  def self.truncate(value)
    value.nil? ? '' : value[0,1024]
  end
end
