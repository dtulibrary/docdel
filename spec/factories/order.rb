FactoryGirl.define do
  factory :order do |f|
    f.atitle "The importance of Testing"
    f.aufirst "Test"
    f.aulast "Testsen"
    f.callback_url "http://localhost/callback"
    f.date "2013"
    f.eissn "19000001"
    f.email "nobody@localhost"
    f.epage "500"
    f.isbn "9788778978642"
    f.issn "05000001"
    f.issue "1"
    f.spage "491"
    f.title "Journal of Testing"
    f.volume "1"
    f.sequence(:customer_order_number) { |n| "T#{n}" }
    f.association :user_type
  end
end
