require "rails_helper"

RSpec.describe Page, type: :model do
  let(:studio) { create(:studio) }
  let(:zine) { create(:zine, studio:) }
  let(:writer) { create(:studio_membership, studio:).writer }

  it "ZINE・担当ライター・タイトルがあれば有効である" do
    page = build(:page, zine:, writer:, title: "夏の名画座")

    expect(page).to be_valid
  end

  describe "title" do
    it "空なら無効である" do
      page = build(:page, zine:, writer:, title: "")

      expect(page).not_to be_valid
    end

    it "30 文字なら有効である" do
      page = build(:page, zine:, writer:, title: "あ" * 30)

      expect(page).to be_valid
    end

    it "31 文字なら無効である" do
      page = build(:page, zine:, writer:, title: "あ" * 31)

      expect(page).not_to be_valid
    end
  end

  describe "body" do
    it "空でも有効である" do
      page = build(:page, zine:, writer:, title: "夏の名画座", body: "")

      expect(page).to be_valid
    end

    it "800 文字なら有効である" do
      page = build(:page, zine:, writer:, title: "夏の名画座", body: "あ" * 800)

      expect(page).to be_valid
    end

    it "801 文字なら無効である" do
      page = build(:page, zine:, writer:, title: "夏の名画座", body: "あ" * 801)

      expect(page).not_to be_valid
    end
  end

  describe "writer" do
    it "スタジオのメンバーでなくても有効である" do
      outside_writer = create(:writer)
      page = build(:page, zine:, writer: outside_writer, title: "夏の名画座")

      expect(page).to be_valid
    end
  end
end
