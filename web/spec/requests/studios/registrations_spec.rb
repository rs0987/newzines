require "rails_helper"

RSpec.describe "招待 URL からの登録", type: :request do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }

  describe "GET /studios/sign_up" do
    context "受諾待ちの招待のトークンのとき" do
      it "登録画面を表示する" do
        invitation = create(:invitation, studio:, username: "writer01")

        get new_studio_registration_path(token: invitation.token)

        expect(response).to have_http_status(:ok)
      end

      it "招待されたユーザー名とスタジオ名を画面に出さない" do
        invitation = create(:invitation, studio:, username: "writer01")

        get new_studio_registration_path(token: invitation.token)

        expect(response.body).not_to include("writer01", "映画好きの集まり")
      end
    end

    context "存在しないトークンのとき" do
      it "無効な招待の画面にリダイレクトする" do
        get new_studio_registration_path(token: "nothing")

        expect(response).to redirect_to(invalid_studio_registration_path)
      end
    end

    context "キャンセル済みの招待のトークンのとき" do
      it "無効な招待の画面にリダイレクトする" do
        invitation = create(:invitation, studio:, username: "writer01", canceled_at: Time.current)

        get new_studio_registration_path(token: invitation.token)

        expect(response).to redirect_to(invalid_studio_registration_path)
      end
    end
  end

  describe "POST /studios/sign_up" do
    let(:invitation) { create(:invitation, studio:, username: "writer01") }

    context "ユーザー名とパスワードが正しいとき" do
      let(:valid_params) { { token: invitation.token, account: { username: "writer01", password: "password12345678" } } }

      it "招待されたユーザー名でアカウントを作る" do
        post studio_registration_path, params: valid_params

        expect(Account.exists?(username: "writer01")).to be true
      end

      it "スタジオのダッシュボードにリダイレクトする" do
        post studio_registration_path, params: valid_params

        expect(response).to redirect_to(studio_root_path("cinema01"))
      end

      it "ログインさせる" do
        post studio_registration_path, params: valid_params
        get studio_root_path("cinema01")

        expect(response).to have_http_status(:ok)
      end
    end

    context "ユーザー名が招待と違うとき" do
      let(:invalid_params) { { token: invitation.token, account: { username: "writer02", password: "password12345678" } } }

      it "アカウントを作らない" do
        post studio_registration_path, params: invalid_params

        expect(Account.count).to eq 0
      end

      it "無効な招待の画面にリダイレクトする" do
        post studio_registration_path, params: invalid_params

        expect(response).to redirect_to(invalid_studio_registration_path)
      end
    end

    context "ユーザー名を大文字で入力したとき" do
      it "小文字にすると招待と一致するので、アカウントを作る" do
        post studio_registration_path, params: { token: invitation.token, account: { username: "Writer01", password: "password12345678" } }

        expect(Account.exists?(username: "writer01")).to be true
      end
    end

    context "パスワードが短いとき" do
      let(:invalid_params) { { token: invitation.token, account: { username: "writer01", password: "a" * 15 } } }

      it "アカウントを作らない" do
        post studio_registration_path, params: invalid_params

        expect(Account.exists?(username: "writer01")).to be false
      end

      it "422 を返して登録画面を再表示する" do
        post studio_registration_path, params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "受諾済みの招待のトークンのとき" do
      before { invitation.update!(accepted_at: Time.current) }

      it "無効な招待の画面にリダイレクトする" do
        post studio_registration_path, params: { token: invitation.token, account: { username: "writer01", password: "password12345678" } }

        expect(response).to redirect_to(invalid_studio_registration_path)
      end
    end
  end

  describe "GET /studios/sign_up/invalid" do
    it "無効な招待の画面を表示する" do
      get invalid_studio_registration_path

      expect(response).to have_http_status(:ok)
    end
  end
end
