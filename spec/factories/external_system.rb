FactoryGirl.define do
  factory :external_system do |f|
    f.sequence(:code) { |n| "externalsystem#{n}" }
  end
end
