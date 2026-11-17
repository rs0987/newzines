require "rails_helper"

RSpec.describe PagePolicy do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }

  describe "Scope" do
    it "発行済みの ZINE の、確定したページだけを返す" do
      published_zine = create(:zine, studio:, title: "発行済み", published_at: Time.current)
      create(:page, zine: published_zine, title: "発行済み・確定", status: :confirmed)
      create(:page, zine: published_zine, title: "発行済み・下書き", status: :draft)
      unpublished_zine = create(:zine, studio:, title: "未発行", published_at: nil)
      create(:page, zine: unpublished_zine, title: "未発行・確定", status: :confirmed)

      pages = described_class::Scope.new(nil, Page).resolve

      expect(pages.map(&:title)).to eq [ "発行済み・確定" ]
    end
  end
end
