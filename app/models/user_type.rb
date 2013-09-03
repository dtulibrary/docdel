class UserType < ActiveRecord::Base
  attr_accessible :code

  validates :code, presence: true, :uniqueness => true

  has_many :orders, :dependent => :restrict

end
