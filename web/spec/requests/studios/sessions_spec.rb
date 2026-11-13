require "rails_helper"

RSpec.describe "スタジオサイトのログインとログアウト", type: :request do
  describe "GET /studios/sign_in" do
    it "ログイン画面を表示する" do
      get new_account_session_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /studios/sign_in" do
    before do
      create(:account, username: "writer01", password: "password12345678")
    end

    context "username とパスワードが正しいとき" do
      it "リダイレクトする" do
        post account_session_path, params: { account: { username: "writer01", password: "password12345678" } }

        expect(response).to be_redirect
      end

      it "管理者サイトにはログインさせない" do
        post account_session_path, params: { account: { username: "writer01", password: "password12345678" } }
        get admin_root_path

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    context "パスワードが違うとき" do
      it "422 を返してログイン画面を再表示する" do
        post account_session_path, params: { account: { username: "writer01", password: "wrongpassword123" } }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "存在しない username のとき" do
      it "422 を返してログイン画面を再表示する" do
        post account_session_path, params: { account: { username: "nobody", password: "password12345678" } }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /studios/sign_out" do
    context "アカウントと管理者の両方でログインしているとき" do
      before do
        sign_in create(:account, username: "writer01", password: "password12345678")
        sign_in create(:administrator, username: "admin01", password: "password12345678")
      end

      it "ログイン画面にリダイレクトする" do
        delete destroy_account_session_path

        expect(response).to redirect_to(new_account_session_path)
      end

      it "管理者のセッションは残す" do
        delete destroy_account_session_path
        get admin_root_path

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
