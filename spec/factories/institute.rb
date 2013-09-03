FactoryGirl.define do
  factory :institute do |f|
    f.sequence(:code) { |n| "institute#{n}" }
  end
end
