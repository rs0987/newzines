require "rails_helper"

RSpec.describe "管理者サイトのダッシュボード", type: :request do
  describe "GET /admin" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get admin_root_path

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    context "管理者としてログインしているとき" do
      before do
        administrator = create(:administrator, username: "admin01", password: "password12345678")
        sign_in administrator
      end

      it "ダッシュボードを表示する" do
        get admin_root_path

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
