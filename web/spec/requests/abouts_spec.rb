require "rails_helper"

RSpec.describe "公開サイトの「このサイトについて」", type: :request do
  describe "GET /about" do
    it "このサイトについてのページを表示する" do
      get about_path

      title = Nokogiri::HTML(response.body).at_css("h1").text
      expect(title.squish).to eq "このサイトについて"
    end
  end
end
