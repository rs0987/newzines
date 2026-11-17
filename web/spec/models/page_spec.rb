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
    it "下書きなら空でも有効である" do
      page = build(:page, zine:, writer:, title: "", status: :draft)

      expect(page).to be_valid
    end

    it "確認中なら空だと無効である" do
      page = build(:page, zine:, writer:, title: "", status: :reviewing)

      expect(page).not_to be_valid
    end

    it "確定なら空だと無効である" do
      page = build(:page, zine:, writer:, title: "", status: :confirmed)

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

    it "\\r\\n の改行を 1 文字として数える" do
      page = build(:page, zine:, writer:, title: "夏の名画座", body: "#{"あ" * 399}\r\n#{"あ" * 400}")

      expect(page).to be_valid
    end
  end

  describe "note" do
    it "空でも有効である" do
      page = build(:page, zine:, writer:, note: "")

      expect(page).to be_valid
    end

    it "200 文字なら有効である" do
      page = build(:page, zine:, writer:, note: "あ" * 200)

      expect(page).to be_valid
    end

    it "201 文字なら無効である" do
      page = build(:page, zine:, writer:, note: "あ" * 201)

      expect(page).not_to be_valid
    end

    it "\\r\\n の改行を 1 文字として数える" do
      page = build(:page, zine:, writer:, note: "#{"あ" * 99}\r\n#{"あ" * 100}")

      expect(page).to be_valid
    end
  end

  describe "position" do
    it "ZINE ごとに 1 から始まり、ページを作るたびに 1 ずつ増える" do
      other_zine = create(:zine, studio:)
      first_page = create(:page, zine:, writer:, title: "夏の名画座")
      other_zine_page = create(:page, zine: other_zine, writer:, title: "読書の秋")
      second_page = create(:page, zine:, writer:, title: "秋の名画座")

      expect([ first_page.position, second_page.position, other_zine_page.position ]).to eq [ 1, 2, 1 ]
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
