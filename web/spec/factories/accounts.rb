FactoryBot.define do
  factory :account do
    sequence(:username) { |n| "account#{n}" }
    password { "password12345678" }
  end
end
