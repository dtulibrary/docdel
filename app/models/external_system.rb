class ExternalSystem < ActiveRecord::Base
  attr_accessible :code

  validates :code, :presence => true, :uniqueness => true

  def name
    I18n.t code, :scope => 'docdel.code.external_system'
  end

end
