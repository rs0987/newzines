FactoryBot.define do
  factory :idea do
    studio
    writer { association(:studio_membership, studio:).writer }
  end
end
