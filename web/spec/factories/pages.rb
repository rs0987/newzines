FactoryBot.define do
  factory :page do
    zine
    writer { association(:studio_membership, studio: zine.studio).writer }
  end
end
