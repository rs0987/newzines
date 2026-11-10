require "rails_helper"

RSpec.describe "管理者のログインとログアウト", type: :request do
  describe "GET /admin/sign_in" do
    it "ログイン画面を表示する" do
      get new_administrator_session_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/sign_in" do
    before do
      create(:administrator, username: "admin01", password: "password12345678")
    end

    context "username とパスワードが正しいとき" do
      it "管理者サイトのトップにリダイレクトする" do
        post administrator_session_path, params: { administrator: { username: "admin01", password: "password12345678" } }

        expect(response).to redirect_to(admin_root_path)
      end
    end

    context "パスワードが違うとき" do
      it "422 を返してログイン画面を再表示する" do
        post administrator_session_path, params: { administrator: { username: "admin01", password: "wrongpassword123" } }

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "ログインさせない" do
        post administrator_session_path, params: { administrator: { username: "admin01", password: "wrongpassword123" } }
        get admin_root_path

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    context "存在しない username のとき" do
      it "422 を返してログイン画面を再表示する" do
        post administrator_session_path, params: { administrator: { username: "nobody", password: "password12345678" } }

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "ログインさせない" do
        post administrator_session_path, params: { administrator: { username: "nobody", password: "password12345678" } }
        get admin_root_path

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end
  end

  describe "DELETE /admin/sign_out" do
    context "ログインしているとき" do
      before do
        administrator = create(:administrator, username: "admin01", password: "password12345678")
        sign_in administrator
      end

      it "ログイン画面にリダイレクトする" do
        delete destroy_administrator_session_path

        expect(response).to redirect_to(new_administrator_session_path)
      end

      it "ログアウトさせる" do
        delete destroy_administrator_session_path
        get admin_root_path

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end
  end
end
