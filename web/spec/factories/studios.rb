FactoryBot.define do
  factory :studio do
    sequence(:name) { |n| "スタジオ#{n}" }
    sequence(:slug) { |n| "studio#{n}" }
  end
end
