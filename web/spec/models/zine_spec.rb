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

  describe "#sort_pages" do
    let(:zine) { create(:zine, studio:, editor:, title: "映画の夏") }

    it "渡したページの順に、position を 1 から振り直す" do
      first_page = create(:page, zine:, title: "夏の名画座")
      second_page = create(:page, zine:, title: "秋の名画座")
      third_page = create(:page, zine:, title: "冬の名画座")

      zine.sort_pages([ third_page.id, first_page.id, second_page.id ])

      expect(zine.pages.reload).to eq [ third_page, first_page, second_page ]
    end

    it "別の ZINE のページが混ざっていたら、どのページも並べ替えない" do
      first_page = create(:page, zine:, title: "夏の名画座")
      second_page = create(:page, zine:, title: "秋の名画座")
      other_zine_page = create(:page, zine: create(:zine, studio:), title: "読書の秋")

      expect {
        zine.sort_pages([ second_page.id, other_zine_page.id, first_page.id ])
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect(zine.pages.reload).to eq [ first_page, second_page ]
    end
  end
end
