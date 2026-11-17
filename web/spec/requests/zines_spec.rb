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

    it "ページを並び順のとおりに表示する" do
      zine = create(:zine, studio:, title: "映画の夏", published_at: Time.current)
      second_page = create(:page, zine:, title: "秋の名画座", status: :confirmed)
      first_page = create(:page, zine:, title: "夏の名画座", status: :confirmed)
      zine.sort_pages([ first_page.id, second_page.id ])

      get zine_path(zine)

      titles = Nokogiri::HTML(response.body).css("h2").map(&:text)
      expect(titles).to eq [ "夏の名画座", "秋の名画座" ]
    end

    it "もくじに、各ページへのリンクを表示する" do
      zine = create(:zine, studio:, title: "映画の夏", published_at: Time.current)
      page = create(:page, zine:, title: "夏の名画座", status: :confirmed)

      get zine_path(zine)

      link = Nokogiri::HTML(response.body).at_css("nav[aria-label='もくじ'] a[href='#page_#{page.id}']")
      expect(link.text.squish).to eq "夏の名画座 1"
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
