# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the
# db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
[
  { code: 'new', },
  { code: 'deliver' },
  { code: 'request' },
  { code: 'fail', },
  { code: 'cancel' },
  { code: 'confirm' },
].each do |o|
  OrderStatus.find_or_create_by_code(o)
end

[
  { code: 'reprintsdesk' },
  { code: 'local_scan' },
].each do |e|
  ExternalSystem.find_or_create_by_code(e)
end

[
  { code: 'not_avail' },
].each do |r|
  Reason.find_or_create_by_code(r)
end

Order.create(
  email: "email@test.dk",
  callback_url: "callback url",
  atitle: "atitle",
  aufirst: "first",
  aulast: "last",
  date: "date",
  delivered_at: "deliv",
  doi: "doi",
  eissn: "eissn",
  epage: "page",
  isbn: "isbn",
  issn: "issn",
  issue: "issue",
  pages: "pages",
  spage: "spage",
  title: "Title",
  volume: "Volume",
  #customer_order_number: "lala"
  #institute_id: ,
  #user_type_id: "lala"

)
