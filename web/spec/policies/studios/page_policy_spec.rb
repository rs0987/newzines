require "rails_helper"

RSpec.describe Studios::PagePolicy do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }
  let(:zine) { create(:zine, studio:, title: "映画の夏") }

  permissions :show?, :create?, :update?, :destroy? do
    it "スタジオのメンバーには許可する" do
      writer = create(:writer)
      create(:studio_membership, studio:, writer:, role: :member)

      expect(described_class).to permit(writer.account, build(:page, zine:, title: "夏の名画座"))
    end

    it "スタジオのメンバーではないライターには許可しない" do
      writer = create(:writer)
      create(:studio_membership, studio: create(:studio, name: "本の虫", slug: "books01"), writer:, role: :owner)

      expect(described_class).not_to permit(writer.account, build(:page, zine:, title: "夏の名画座"))
    end
  end

  describe "Scope" do
    it "所属しているスタジオの ZINE のページだけを返す" do
      writer = create(:writer)
      create(:studio_membership, studio:, writer:, role: :member)
      own_page = create(:page, zine:, title: "夏の名画座")
      create(:page, zine: create(:zine, studio: create(:studio, name: "本の虫", slug: "books01"), title: "読書の秋"), title: "秋の文庫本")

      pages = described_class::Scope.new(writer.account, Page).resolve

      expect(pages).to eq [ own_page ]
    end
  end
end
