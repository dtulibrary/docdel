class UserType < ActiveRecord::Base
  attr_accessible :code

  validates :code, presence: true, :uniqueness => true

  has_many :orders, :dependent => :restrict

  def name
    I18n.t(code, :scope => 'docdel.code.user_type')
  end

end
