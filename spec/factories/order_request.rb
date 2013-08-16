FactoryGirl.define do
  factory :order_request do |f|
    f.association :order
    f.association :order_status
    f.association :external_system
    f.external_number 1
    f.external_url "http://external.test.com/external_reference.html"
    f.shelfmark "Shelf 1"
  end
end
