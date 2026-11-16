require "rails_helper"

RSpec.describe "公開サイトのホーム", type: :request do
  describe "GET /" do
    it "発行済みの ZINE を、発行日時の新しい順に表示する" do
      studio = create(:studio, name: "映画好きの集まり", slug: "cinema01")
      create(:zine, studio:, title: "映画の春", published_at: 2.days.ago)
      create(:zine, studio:, title: "映画の夏", published_at: 1.day.ago)

      get root_path

      titles = Nokogiri::HTML(response.body).css("h3").map(&:text)
      expect(titles).to eq [ "映画の夏", "映画の春" ]
    end

    it "未発行の ZINE は表示しない" do
      studio = create(:studio, name: "映画好きの集まり", slug: "cinema01")
      create(:zine, studio:, title: "映画の秋", published_at: nil)

      get root_path

      expect(response.body).not_to include("映画の秋")
    end
  end
end
