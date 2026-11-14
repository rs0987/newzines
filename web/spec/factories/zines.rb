FactoryBot.define do
  factory :zine do
    studio
    sequence(:title) { |n| "ZINE#{n}" }
    editor { association(:studio_membership, studio:).writer }
  end
end
