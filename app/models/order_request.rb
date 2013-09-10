class OrderRequest < ActiveRecord::Base
  belongs_to :order
  belongs_to :order_status
  belongs_to :external_system
  attr_accessible :external_copyright_charge, :external_currency,
    :external_number, :external_service_charge, :external_url, :shelfmark,
    :reason_id, :reason_text

  validates :order, :presence => true
  validates :order_status, :presence => true
  validates :external_system, :presence => true

  belongs_to :reason

  scope :current, :limit => 1, :order => 'created_at DESC'

  def deliver(url)
    self.external_url = url
    set_status('deliver')
    order.mark_delivery(url)
  end

  def confirm
    set_status('confirm')
    order.do_callback('confirm')
  end

  def cancel
    return if order_status.code == 'cancel'
    set_status('cancel')
    order.reason = format_reason
    order.do_callback('cancel')
  end

  def format_reason
    reason = ''
    reason = self.reason.name if self.reason_id
    unless self.reason_text.blank?
      reason += ': ' unless reason.blank?
      reason += self.reason_text
    end
    reason
  end

  private

  def set_status(code)
    self.order_status_id = OrderStatus.find_by_code(code).id
    save!
  end

end
