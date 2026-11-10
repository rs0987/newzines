FactoryBot.define do
  factory :administrator do
    sequence(:username) { |n| "admin#{n}" }
    password { "password12345678" }
  end
end
