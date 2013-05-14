class User < ActiveRecord::Base
  devise :cas_authenticatable

  attr_accessible :username

  validates :username, :presence => true, :uniqueness => true
end
