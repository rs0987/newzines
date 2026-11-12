FactoryBot.define do
  factory :invitation do
    studio
    inviter factory: :administrator
    sequence(:username) { |n| "writer#{n}" }
  end
end
