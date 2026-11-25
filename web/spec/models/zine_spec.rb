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

    it "\\r\\n の改行を 1 文字として数える" do
      zine = build(:zine, studio:, editor:, title: "映画の夏", description: "#{"あ" * 99}\r\n#{"あ" * 100}")

      expect(zine).to be_valid
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

  describe "theme_color" do
    it "選べるテーマカラーなら有効である" do
      zine = build(:zine, studio:, editor:, title: "映画の夏", theme_color: "abyss")

      expect(zine).to be_valid
    end

    it "選べないテーマカラーなら無効である" do
      zine = build(:zine, studio:, editor:, title: "映画の夏", theme_color: "lofi")

      expect(zine).not_to be_valid
    end
  end

  describe "#published?" do
    it "発行日時があれば true を返す" do
      zine = build(:zine, studio:, editor:, title: "映画の夏", published_at: Time.current)

      expect(zine.published?).to be true
    end

    it "発行日時がなければ false を返す" do
      zine = build(:zine, studio:, editor:, title: "映画の夏", published_at: nil)

      expect(zine.published?).to be false
    end
  end

  describe "#publishable?" do
    let(:zine) { create(:zine, studio:, editor:, title: "映画の夏") }

    it "すべてのページが確定なら true を返す" do
      create(:page, zine:, title: "夏の名画座", status: :confirmed)
      create(:page, zine:, title: "秋の名画座", status: :confirmed)

      expect(zine.publishable?).to be true
    end

    it "確定ではないページが 1 枚でもあれば false を返す" do
      create(:page, zine:, title: "夏の名画座", status: :confirmed)
      create(:page, zine:, title: "秋の名画座", status: :reviewing)

      expect(zine.publishable?).to be false
    end

    it "ページが 1 枚もなければ false を返す" do
      expect(zine.publishable?).to be false
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
