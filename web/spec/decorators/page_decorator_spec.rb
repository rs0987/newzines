require "rails_helper"

RSpec.describe PageDecorator do
  let(:studio) { create(:studio) }
  let(:zine) { create(:zine, studio:) }
  let(:writer) { create(:studio_membership, studio:).writer }

  describe "#display_title" do
    it "タイトルがあれば、タイトルを返す" do
      page = create(:page, zine:, writer:, title: "夏の名画座")

      display_title = described_class.new(page).display_title

      expect(display_title).to eq "夏の名画座"
    end

    it "タイトルが空なら、（タイトル未定）を返す" do
      page = create(:page, zine:, writer:, title: "", status: :draft)

      display_title = described_class.new(page).display_title

      expect(display_title).to eq "（タイトル未定）"
    end

    it "まだ保存していないタイトルではなく、保存済みのタイトルを返す" do
      page = create(:page, zine:, writer:, title: "夏の名画座")
      page.title = "秋の名画座"

      display_title = described_class.new(page).display_title

      expect(display_title).to eq "夏の名画座"
    end
  end
end
