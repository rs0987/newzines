require "rails_helper"

RSpec.describe "公開サイトの ZINE", type: :request do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }

  describe "GET /zines/:id" do
    it "発行済みなら、タイトルと説明を表示する" do
      zine = create(:zine, studio:, title: "映画の夏", description: "夏に観たい名作を紹介します", published_at: Time.current)

      get zine_path(zine)

      html = Nokogiri::HTML(response.body)
      expect([ html.at_css("h1").text, html.at_css("h1").next_element.text ]).to eq [ "映画の夏", "夏に観たい名作を紹介します" ]
    end

    it "未発行なら 404 を返す" do
      zine = create(:zine, studio:, title: "映画の夏", published_at: nil)

      get zine_path(zine)

      expect(response).to have_http_status(:not_found)
    end

    it "存在しなければ 404 を返す" do
      get zine_path(0)

      expect(response).to have_http_status(:not_found)
    end
  end
end
