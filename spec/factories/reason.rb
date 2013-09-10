FactoryGirl.define do
  factory :reason do |f|
    f.sequence(:code) { |n| "reason#{n}" }
  end
end
