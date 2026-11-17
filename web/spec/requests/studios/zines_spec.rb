require "rails_helper"

RSpec.describe "スタジオサイトの ZINE 管理", type: :request do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }
  let(:writer) { create(:writer, account: create(:account, username: "writer01", password: "password12345678")) }

  before { create(:studio_membership, studio:, writer:, role: :member) }

  describe "GET /studios/:studio_slug/zines" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get studio_zines_path(studio.slug)

        expect(response).to redirect_to(new_account_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "ZINE の一覧を表示する" do
        create(:zine, studio:, editor: writer, title: "映画の夏")

        get studio_zines_path(studio.slug)

        expect(response.body).to include("映画の夏")
      end
    end
  end

  describe "GET /studios/:studio_slug/zines/:id" do
    context "ログインしているとき" do
      before { sign_in writer.account }

      it "ZINE の詳細を表示する" do
        zine = create(:zine, studio:, editor: writer, title: "映画の夏")

        get studio_zine_path(studio.slug, zine)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /studios/:studio_slug/zines/new" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get new_studio_zine_path(studio.slug)

        expect(response).to redirect_to(new_account_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "作成画面を表示する" do
        get new_studio_zine_path(studio.slug)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /studios/:studio_slug/zines" do
    let(:valid_params) { { zine: { title: "映画の夏", description: "夏に観たい映画を集めました", editor_id: writer.id } } }

    context "ログインしていないとき" do
      it "ZINE を作成しない" do
        expect {
          post studio_zines_path(studio.slug), params: valid_params
        }.not_to change(Zine, :count)
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      context "入力が正しいとき" do
        it "ZINE を作成する" do
          post studio_zines_path(studio.slug), params: valid_params

          zine = studio.zines.find_by(title: "映画の夏")
          expect([ zine.description, zine.editor ]).to eq [ "夏に観たい映画を集めました", writer ]
        end

        it "作成した ZINE の詳細画面にリダイレクトする" do
          post studio_zines_path(studio.slug), params: valid_params

          zine = studio.zines.find_by(title: "映画の夏")
          expect(response).to redirect_to(studio_zine_path(studio.slug, zine))
        end
      end

      context "入力が正しくないとき" do
        let(:invalid_params) { { zine: { title: "", description: "夏に観たい映画を集めました", editor_id: writer.id } } }

        it "ZINE を作成しない" do
          expect {
            post studio_zines_path(studio.slug), params: invalid_params
          }.not_to change(Zine, :count)
        end

        it "422 を返して作成画面を再表示する" do
          post studio_zines_path(studio.slug), params: invalid_params

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe "GET /studios/:studio_slug/zines/:id/edit" do
    context "ログインしているとき" do
      before { sign_in writer.account }

      it "編集画面を表示する" do
        zine = create(:zine, studio:, editor: writer, title: "映画の夏")

        get edit_studio_zine_path(studio.slug, zine)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PATCH /studios/:studio_slug/zines/:id" do
    let(:zine) { create(:zine, studio:, editor: writer, title: "映画の夏") }

    context "ログインしていないとき" do
      it "タイトルを更新しない" do
        patch studio_zine_path(studio.slug, zine), params: { zine: { title: "映画の秋" } }

        expect(zine.reload.title).to eq "映画の夏"
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      context "入力が正しいとき" do
        let(:other_writer) { create(:studio_membership, studio:, role: :member).writer }
        let(:valid_params) { { zine: { title: "映画の秋", description: "秋に観たい映画を集めました", editor_id: other_writer.id, theme_color: "abyss" } } }

        it "ZINE を更新する" do
          patch studio_zine_path(studio.slug, zine), params: valid_params

          zine.reload
          expect([ zine.title, zine.description, zine.editor, zine.theme_color ]).to eq [ "映画の秋", "秋に観たい映画を集めました", other_writer, "abyss" ]
        end

        it "ZINE の詳細画面にリダイレクトする" do
          patch studio_zine_path(studio.slug, zine), params: valid_params

          expect(response).to redirect_to(studio_zine_path(studio.slug, zine))
        end
      end

      context "入力が正しくないとき" do
        it "422 を返して編集画面を再表示する" do
          patch studio_zine_path(studio.slug, zine), params: { zine: { title: "" } }

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe "DELETE /studios/:studio_slug/zines/:id" do
    let(:zine) { create(:zine, studio:, editor: writer, title: "映画の夏") }

    context "ログインしていないとき" do
      it "ZINE を削除しない" do
        delete studio_zine_path(studio.slug, zine)

        expect(Zine.exists?(zine.id)).to be true
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "ZINE を削除する" do
        delete studio_zine_path(studio.slug, zine)

        expect(Zine.exists?(zine.id)).to be false
      end

      it "303 で ZINE 一覧にリダイレクトする" do
        delete studio_zine_path(studio.slug, zine)

        expect([ response.status, response.location ]).to eq [ 303, studio_zines_url(studio.slug) ]
      end
    end
  end
end
