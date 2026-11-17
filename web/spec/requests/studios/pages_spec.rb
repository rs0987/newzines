require "rails_helper"

RSpec.describe "スタジオサイトのページ管理", type: :request do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }
  let(:writer) { create(:writer, account: create(:account, username: "writer01", password: "password12345678")) }
  let(:zine) { create(:zine, studio:, editor: writer, title: "映画の夏") }

  before { create(:studio_membership, studio:, writer:, role: :member) }

  describe "GET /studios/:studio_slug/zines/:zine_id/pages" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get studio_zine_pages_path(studio.slug, zine)

        expect(response).to redirect_to(new_account_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "ページの一覧を表示する" do
        create(:page, zine:, writer:, title: "夏の名画座")

        get studio_zine_pages_path(studio.slug, zine)

        expect(response.body).to include("夏の名画座")
      end
    end
  end

  describe "GET /studios/:studio_slug/zines/:zine_id/pages/:id" do
    context "ログインしているとき" do
      before { sign_in writer.account }

      it "ページの詳細を表示する" do
        page = create(:page, zine:, writer:)

        get studio_zine_page_path(studio.slug, zine, page)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /studios/:studio_slug/zines/:zine_id/pages/new" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get new_studio_zine_page_path(studio.slug, zine)

        expect(response).to redirect_to(new_account_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "追加画面を表示する" do
        get new_studio_zine_page_path(studio.slug, zine)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /studios/:studio_slug/zines/:zine_id/pages" do
    let(:valid_params) { { page: { writer_id: writer.id, note: "夏に観た映画を 1 本紹介してください" } } }

    context "ログインしていないとき" do
      it "ページを追加しない" do
        expect {
          post studio_zine_pages_path(studio.slug, zine), params: valid_params
        }.not_to change(Page, :count)
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      context "入力が正しいとき" do
        it "ページを追加する" do
          post studio_zine_pages_path(studio.slug, zine), params: valid_params

          page = zine.pages.last
          expect([ page.writer, page.note ]).to eq [ writer, "夏に観た映画を 1 本紹介してください" ]
        end

        it "追加したページの詳細画面にリダイレクトする" do
          post studio_zine_pages_path(studio.slug, zine), params: valid_params

          page = zine.pages.last
          expect(response).to redirect_to(studio_zine_page_path(studio.slug, zine, page))
        end
      end

      context "入力が正しくないとき" do
        let(:invalid_params) { { page: { writer_id: "" } } }

        it "ページを追加しない" do
          expect {
            post studio_zine_pages_path(studio.slug, zine), params: invalid_params
          }.not_to change(Page, :count)
        end

        it "422 を返して追加画面を再表示する" do
          post studio_zine_pages_path(studio.slug, zine), params: invalid_params

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe "GET /studios/:studio_slug/zines/:zine_id/pages/:id/edit" do
    context "ログインしているとき" do
      before { sign_in writer.account }

      it "編集画面を表示する" do
        page = create(:page, zine:, writer:)

        get edit_studio_zine_page_path(studio.slug, zine, page)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PATCH /studios/:studio_slug/zines/:zine_id/pages/:id" do
    let(:page) { create(:page, zine:, writer:) }
    let(:other_writer) { create(:studio_membership, studio:, role: :member).writer }
    let(:valid_params) { { page: { writer_id: other_writer.id, note: "秋に観た映画を 1 本紹介してください" } } }

    context "ログインしていないとき" do
      it "ページを更新しない" do
        patch studio_zine_page_path(studio.slug, zine, page), params: valid_params

        expect(page.reload.writer).to eq writer
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      context "入力が正しいとき" do
        it "ページを更新する" do
          patch studio_zine_page_path(studio.slug, zine, page), params: valid_params

          page.reload
          expect([ page.writer, page.note ]).to eq [ other_writer, "秋に観た映画を 1 本紹介してください" ]
        end

        it "ページの詳細画面にリダイレクトする" do
          patch studio_zine_page_path(studio.slug, zine, page), params: valid_params

          expect(response).to redirect_to(studio_zine_page_path(studio.slug, zine, page))
        end
      end

      context "入力が正しくないとき" do
        it "422 を返して編集画面を再表示する" do
          patch studio_zine_page_path(studio.slug, zine, page), params: { page: { writer_id: "" } }

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe "DELETE /studios/:studio_slug/zines/:zine_id/pages/:id" do
    let(:page) { create(:page, zine:, writer:) }

    context "ログインしていないとき" do
      it "ページを削除しない" do
        delete studio_zine_page_path(studio.slug, zine, page)

        expect(Page.exists?(page.id)).to be true
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "ページを削除する" do
        delete studio_zine_page_path(studio.slug, zine, page)

        expect(Page.exists?(page.id)).to be false
      end

      it "303 でページの一覧にリダイレクトする" do
        delete studio_zine_page_path(studio.slug, zine, page)

        expect([ response.status, response.location ]).to eq [ 303, studio_zine_pages_url(studio.slug, zine) ]
      end
    end
  end

  describe "PATCH /studios/:studio_slug/zines/:zine_id/pages/:id/submit" do
    let(:page_writer) { create(:studio_membership, studio:, role: :member).writer }
    let(:page) { create(:page, zine:, writer: page_writer, title: "夏の名画座", status: :draft) }

    context "ログインしていないとき" do
      it "ページを提出しない" do
        patch submit_studio_zine_page_path(studio.slug, zine, page)

        expect(page.reload.status).to eq "draft"
      end
    end

    context "担当ライターとしてログインしているとき" do
      before { sign_in page_writer.account }

      it "ページを確認中にする" do
        patch submit_studio_zine_page_path(studio.slug, zine, page)

        expect(page.reload.status).to eq "reviewing"
      end

      it "303 でページの詳細画面にリダイレクトする" do
        patch submit_studio_zine_page_path(studio.slug, zine, page)

        expect([ response.status, response.location ]).to eq [ 303, studio_zine_page_url(studio.slug, zine, page) ]
      end

      it "タイトルが空なら、下書きのままにする" do
        page.update!(title: "")

        patch submit_studio_zine_page_path(studio.slug, zine, page)

        expect(page.reload.status).to eq "draft"
      end

      it "タイトルが空なら、理由を表示する" do
        page.update!(title: "")

        patch submit_studio_zine_page_path(studio.slug, zine, page)

        expect(flash[:alert]).to eq "タイトルを入力してください"
      end
    end
  end

  describe "PATCH /studios/:studio_slug/zines/:zine_id/pages/:id/confirm" do
    context "ログインしていないとき" do
      it "ページを確定しない" do
        page = create(:page, zine:, title: "夏の名画座", status: :reviewing)

        patch confirm_studio_zine_page_path(studio.slug, zine, page)

        expect(page.reload.status).to eq "reviewing"
      end
    end

    context "責任編集者としてログインしているとき" do
      before { sign_in writer.account }

      it "確認中のページを確定にする" do
        page = create(:page, zine:, title: "夏の名画座", status: :reviewing)

        patch confirm_studio_zine_page_path(studio.slug, zine, page)

        expect(page.reload.status).to eq "confirmed"
      end

      it "自分が担当する下書きのページを、提出せずに確定にする" do
        page = create(:page, zine:, writer:, title: "夏の名画座", status: :draft)

        patch confirm_studio_zine_page_path(studio.slug, zine, page)

        expect(page.reload.status).to eq "confirmed"
      end

      it "自分が担当する下書きのページでも、タイトルが空なら下書きのままにする" do
        page = create(:page, zine:, writer:, title: "", status: :draft)

        patch confirm_studio_zine_page_path(studio.slug, zine, page)

        expect(page.reload.status).to eq "draft"
      end

      it "303 でページの詳細画面にリダイレクトする" do
        page = create(:page, zine:, title: "夏の名画座", status: :reviewing)

        patch confirm_studio_zine_page_path(studio.slug, zine, page)

        expect([ response.status, response.location ]).to eq [ 303, studio_zine_page_url(studio.slug, zine, page) ]
      end
    end
  end

  describe "PATCH /studios/:studio_slug/zines/:zine_id/pages/:id/send_back" do
    let(:page) { create(:page, zine:, title: "夏の名画座", status: :confirmed) }

    context "ログインしていないとき" do
      it "ページを差し戻さない" do
        patch send_back_studio_zine_page_path(studio.slug, zine, page)

        expect(page.reload.status).to eq "confirmed"
      end
    end

    context "責任編集者としてログインしているとき" do
      before { sign_in writer.account }

      it "ページを下書きに戻す" do
        patch send_back_studio_zine_page_path(studio.slug, zine, page)

        expect(page.reload.status).to eq "draft"
      end

      it "303 でページの詳細画面にリダイレクトする" do
        patch send_back_studio_zine_page_path(studio.slug, zine, page)

        expect([ response.status, response.location ]).to eq [ 303, studio_zine_page_url(studio.slug, zine, page) ]
      end
    end
  end
end
