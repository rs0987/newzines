require "rails_helper"

RSpec.describe Idea, type: :model do
  let(:studio) { create(:studio) }
  let(:writer) { create(:studio_membership, studio:).writer }

  it "スタジオ・ライターがあれば有効である" do
    idea = build(:idea, studio:, writer:)

    expect(idea).to be_valid
  end

  describe "title" do
    it "改行を空白に置き換える" do
      idea = build(:idea, studio:, writer:, title: "夏の\r\n名画座")

      expect(idea.title).to eq "夏の 名画座"
    end
  end

  describe "body" do
    it "改行を空白に置き換える" do
      idea = build(:idea, studio:, writer:, body: "名画座の\n夏の特集")

      expect(idea.body).to eq "名画座の 夏の特集"
    end
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
