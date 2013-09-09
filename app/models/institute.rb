class Institute < ActiveRecord::Base
  attr_accessible :code

  validates :code, presence: true, :uniqueness => true

  has_many :orders, :dependent => :restrict

  def name
    code
  end
end
