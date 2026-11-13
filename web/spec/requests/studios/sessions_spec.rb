require "rails_helper"

RSpec.describe "スタジオサイトのログインとログアウト", type: :request do
  describe "GET /studios/sign_in" do
    it "ログイン画面を表示する" do
      get new_account_session_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /studios/sign_in" do
    let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }

    context "スタジオに所属しているとき" do
      before do
        writer = create(:writer, account: create(:account, username: "writer01", password: "password12345678"))
        create(:studio_membership, studio:, writer:, role: :owner)
      end

      context "username とパスワードが正しいとき" do
        it "所属しているスタジオのトップにリダイレクトする" do
          post account_session_path, params: { account: { username: "writer01", password: "password12345678" } }

          expect(response).to redirect_to(studio_root_path("cinema01"))
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

        it "ログインさせない" do
          post account_session_path, params: { account: { username: "writer01", password: "wrongpassword123" } }
          get studio_root_path("cinema01")

          expect(response).to redirect_to(new_account_session_path)
        end
      end

      context "存在しない username のとき" do
        it "422 を返してログイン画面を再表示する" do
          post account_session_path, params: { account: { username: "nobody", password: "password12345678" } }

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "ログイン前にスタジオのページを開こうとしていたとき" do
      before do
        writer = create(:writer, account: create(:account, username: "writer01", password: "password12345678"))
        create(:studio_membership, studio:, writer:, role: :owner)
        create(:studio_membership, studio: create(:studio, name: "本の虫", slug: "books01"), writer:, role: :member)
      end

      it "開こうとしていたページにリダイレクトする" do
        get studio_root_path("books01")
        post account_session_path, params: { account: { username: "writer01", password: "password12345678" } }

        expect(response).to redirect_to(studio_root_path("books01"))
      end
    end

    context "どのスタジオにも所属していないとき" do
      before do
        create(:account, username: "writer01", password: "password12345678")
      end

      it "ログイン画面にリダイレクトする" do
        post account_session_path, params: { account: { username: "writer01", password: "password12345678" } }

        expect(response).to redirect_to(new_account_session_path)
      end

      it "ログインさせない" do
        post account_session_path, params: { account: { username: "writer01", password: "password12345678" } }
        get new_account_session_path

        expect(response).to have_http_status(:ok)
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
