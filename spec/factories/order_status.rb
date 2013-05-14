FactoryGirl.define do
  factory :order_status do |f|
    f.sequence(:code) { |n| "orderstatus#{n}" }
  end
end
