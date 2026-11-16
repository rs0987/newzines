require "rails_helper"

RSpec.describe ZinePolicy do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }

  permissions :show? do
    it "発行済みなら許可する" do
      expect(described_class).to permit(nil, build(:zine, studio:, title: "映画の夏", published_at: Time.current))
    end

    it "未発行なら許可しない" do
      expect(described_class).not_to permit(nil, build(:zine, studio:, title: "映画の夏", published_at: nil))
    end
  end

  describe "Scope" do
    it "発行済みの ZINE だけを返す" do
      published_zine = create(:zine, studio:, title: "映画の夏", published_at: Time.current)
      create(:zine, studio:, title: "映画の秋", published_at: nil)

      zines = described_class::Scope.new(nil, Zine).resolve

      expect(zines).to eq [ published_zine ]
    end
  end
end
