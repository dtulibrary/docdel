class OrderStatus < ActiveRecord::Base
  attr_accessible :code, :priority

  validates :code, :presence => true, :uniqueness => true

  def name
    I18n.t code, :scope => 'docdel.code.order_status'
  end
end
