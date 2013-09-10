class Reason < ActiveRecord::Base
  attr_accessible :code

  validates :code, :presence => true, :uniqueness => true

  has_many :order_requests, :dependent => :restrict

  def name
    I18n.t(code, :scope => 'haitatsu.code.reason')
  end
end
