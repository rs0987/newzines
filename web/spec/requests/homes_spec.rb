require "rails_helper"

RSpec.describe "公開サイトのホーム", type: :request do
  describe "GET /" do
    it "200 を返す" do
      get root_path

      expect(response).to have_http_status(:ok)
    end
  end
end
