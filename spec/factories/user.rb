FactoryGirl.define do
  factory :user do |f|
    f.sequence(:username) { |n| "user#{n}" }
  end
end
