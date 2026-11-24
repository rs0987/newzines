require "rails_helper"

RSpec.describe Idea, type: :model do
  let(:studio) { create(:studio) }
  let(:writer) { create(:studio_membership, studio:).writer }

  it "スタジオ・ライターがあれば有効である" do
    idea = build(:idea, studio:, writer:)

    expect(idea).to be_valid
  end

  describe "writer" do
    it "スタジオのメンバーでなければ無効である" do
      idea = build(:idea, studio:, writer: create(:writer))

      expect(idea).not_to be_valid
    end

    it "別のスタジオのメンバーなら無効である" do
      other_studio_writer = create(:studio_membership, studio: create(:studio)).writer
      idea = build(:idea, studio:, writer: other_studio_writer)

      expect(idea).not_to be_valid
    end
  end
end
