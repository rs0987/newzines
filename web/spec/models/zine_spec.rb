require "rails_helper"

RSpec.describe Zine, type: :model do
  let(:studio) { create(:studio) }
  let(:editor) { create(:studio_membership, studio:).writer }

  it "スタジオ・責任編集者・タイトルがあれば有効である" do
    zine = build(:zine, studio:, editor:, title: "映画の夏")

    expect(zine).to be_valid
  end

  describe "title" do
    it "空なら無効である" do
      zine = build(:zine, studio:, editor:, title: "")

      expect(zine).not_to be_valid
    end

    it "30 文字なら有効である" do
      zine = build(:zine, studio:, editor:, title: "あ" * 30)

      expect(zine).to be_valid
    end

    it "31 文字なら無効である" do
      zine = build(:zine, studio:, editor:, title: "あ" * 31)

      expect(zine).not_to be_valid
    end
  end

  describe "description" do
    it "空でも有効である" do
      zine = build(:zine, studio:, editor:, title: "映画の夏", description: "")

      expect(zine).to be_valid
    end

    it "200 文字なら有効である" do
      zine = build(:zine, studio:, editor:, title: "映画の夏", description: "あ" * 200)

      expect(zine).to be_valid
    end

    it "201 文字なら無効である" do
      zine = build(:zine, studio:, editor:, title: "映画の夏", description: "あ" * 201)

      expect(zine).not_to be_valid
    end
  end

  describe "editor" do
    it "スタジオのメンバーでなければ無効である" do
      zine = build(:zine, studio:, editor: create(:writer), title: "映画の夏")

      expect(zine).not_to be_valid
    end

    it "別のスタジオのメンバーなら無効である" do
      other_studio_writer = create(:studio_membership, studio: create(:studio)).writer
      zine = build(:zine, studio:, editor: other_studio_writer, title: "映画の夏")

      expect(zine).not_to be_valid
    end
  end
end
