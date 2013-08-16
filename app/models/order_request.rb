class OrderRequest < ActiveRecord::Base
  belongs_to :order
  belongs_to :order_status
  belongs_to :external_system
  attr_accessible :external_copyright_charge, :external_currency,
    :external_number, :external_service_charge, :external_url, :shelfmark

  validates :order, :presence => true
  validates :order_status, :presence => true
  validates :external_system, :presence => true

  scope :current, :limit => 1, :order => 'created_at DESC'

  def deliver(url)
    external_url = url
    set_status('deliver')
    order.mark_delivery
  end

  def confirm
    set_status('confirm')
    order.do_callback('confirm')
  end

  def cancel
    set_status('cancel')
    order.do_callback('cancel')
  end

  private

  def set_status(code)
    self.order_status_id = OrderStatus.find_by_code(code).id
    save!
  end

end
