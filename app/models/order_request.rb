class OrderRequest < ActiveRecord::Base
  belongs_to :order
  belongs_to :order_status
  belongs_to :external_system
  attr_accessible :external_copyright_charge, :external_currency,
    :external_number, :external_service_charge, :external_url, :shelfmark,
    :reason_id, :reason_text, :order_status_id

  validates :order, :presence => true
  validates :order_status, :presence => true
  validates :external_system, :presence => true

  belongs_to :reason

  scope :current, :limit => 1, :order => 'created_at DESC'

  def deliver(url)
    self.external_url = url
    order.mark_delivery(url)
    set_status('deliver')
  end

  def confirm(external_number = nil)
    order.do_callback('confirm', :supplier_order_id => external_number)
    set_status('confirm')
  end

  def cancel
    return if order_status.code == 'cancel'
    order.reason = format_reason
    order.do_callback('cancel')
    set_status('cancel')
  end

  def format_reason
    "#{self.reason_id.nil? ? '' : "#{self.reason.name}: "}#{self.reason_text || ''}"
  end

  private

  def set_status(code)
    self.order_status = OrderStatus.find_by_code(code)
    save!
  end

end
