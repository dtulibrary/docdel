class Order < ActiveRecord::Base
  attr_accessible :atitle, :aufirst, :aulast, :callback_url, :date,
    :delivered_at, :doi, :eissn, :email, :epage, :isbn, :issn, :issue, :pages,
    :spage, :title, :volume

  validates :email, :presence => true
  validates :callback_url, :presence => true
end
