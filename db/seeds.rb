# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
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
].each do |o|
  OrderStatus.find_or_create_by_code(o)
end

[
  { code: 'reprintsdesk' },
  { code: 'local_scan' },
].each do |e|
  ExternalSystem.find_or_create_by_code(e)
end
