require "rails_helper"

RSpec.describe "スタジオサイトのページ内容編集", type: :request do
  let(:studio) { create(:studio) }
  let(:writer) { create(:writer) }
  let(:zine) { create(:zine, studio:, editor: writer, title: "映画の夏") }
  let(:page) { create(:page, zine:, writer:, title: "仮タイトル") }

  before { create(:studio_membership, studio:, writer:, role: :member) }

  describe "GET /studios/:studio_slug/zines/:zine_id/pages/:page_id/writing/edit" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get edit_studio_zine_page_writing_path(studio.slug, zine, page)

        expect(response).to redirect_to(new_account_session_path)
      end
    end

    context "担当ライターとしてログインしているとき" do
      before { sign_in writer.account }

      it "ページ内容編集画面を表示する" do
        get edit_studio_zine_page_writing_path(studio.slug, zine, page)

        expect(response).to have_http_status(:ok)
      end
    end

    context "担当ではないスタジオのメンバーとしてログインしているとき" do
      before do
        other_writer = create(:studio_membership, studio:, role: :member).writer
        sign_in other_writer.account
      end

      it "303 でスタジオのトップにリダイレクトする" do
        get edit_studio_zine_page_writing_path(studio.slug, zine, page)

        expect([ response.status, response.location ]).to eq [ 303, studio_root_url(studio.slug) ]
      end
    end
  end

  describe "PATCH /studios/:studio_slug/zines/:zine_id/pages/:page_id/writing" do
    let(:valid_params) { { page: { title: "夏の名画座", body: "夏に観たい映画を集めました。" } } }

    context "ログインしていないとき" do
      it "ページを更新しない" do
        patch studio_zine_page_writing_path(studio.slug, zine, page), params: valid_params

        expect(page.reload.title).to eq "仮タイトル"
      end
    end

    context "担当ライターとしてログインしているとき" do
      before { sign_in writer.account }

      context "入力が正しいとき" do
        it "タイトルと本文を更新する" do
          patch studio_zine_page_writing_path(studio.slug, zine, page), params: valid_params

          page.reload
          expect([ page.title, page.body ]).to eq [ "夏の名画座", "夏に観たい映画を集めました。" ]
        end

        it "ページの詳細画面にリダイレクトする" do
          patch studio_zine_page_writing_path(studio.slug, zine, page), params: valid_params

          expect(response).to redirect_to(studio_zine_page_path(studio.slug, zine, page))
        end
      end

      context "入力が正しくないとき" do
        it "422 を返してページ内容編集画面を再表示する" do
          patch studio_zine_page_writing_path(studio.slug, zine, page), params: { page: { title: "夏の名画座", body: "あ" * 801 } }

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end
end
