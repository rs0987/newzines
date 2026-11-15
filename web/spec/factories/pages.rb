FactoryBot.define do
  factory :page do
    zine
    sequence(:title) { |n| "ページ#{n}" }
    writer { association(:studio_membership, studio: zine.studio).writer }
  end
end
