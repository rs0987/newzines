require "rails_helper"

RSpec.describe Idea, type: :model do
  let(:studio) { create(:studio) }
  let(:writer) { create(:studio_membership, studio:).writer }

  it "スタジオ・ライターがあれば有効である" do
    idea = build(:idea, studio:, writer:)

    expect(idea).to be_valid
  end
end
