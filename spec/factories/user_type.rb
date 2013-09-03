FactoryGirl.define do
  factory :user_type do |f|
    f.sequence(:code) { |n| "usertype#{n}" }
  end
end
