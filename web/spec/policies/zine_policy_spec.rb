require "rails_helper"

RSpec.describe ZinePolicy do
  describe "Scope" do
    it "発行済みの ZINE だけを返す" do
      studio = create(:studio, name: "映画好きの集まり", slug: "cinema01")
      published_zine = create(:zine, studio:, title: "映画の夏", published_at: Time.current)
      create(:zine, studio:, title: "映画の秋", published_at: nil)

      zines = described_class::Scope.new(nil, Zine).resolve

      expect(zines).to eq [ published_zine ]
    end
  end
end
