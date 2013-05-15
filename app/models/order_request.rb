class OrderRequest < ActiveRecord::Base
  belongs_to :order
  belongs_to :order_status
  belongs_to :external_system
  attr_accessible :external_copyright_charge, :external_currency, :external_id,
    :external_service_charge, :external_url, :shelfmark

  validates :order, :presence => true
  validates :order_status, :presence => true
  validates :external_system, :presence => true
end
