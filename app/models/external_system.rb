class ExternalSystem < ActiveRecord::Base
  attr_accessible :code

  validates :code, :presence => true, :uniqueness => true

  def name
    I18n.t code, :scope => 'haitatsu.code.external_system'
  end

end
