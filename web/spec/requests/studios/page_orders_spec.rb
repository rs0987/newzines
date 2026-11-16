require "rails_helper"

RSpec.describe "スタジオサイトのページの並べ替え", type: :request do
  let(:studio) { create(:studio) }
  let(:writer) { create(:writer) }
  let(:zine) { create(:zine, studio:, editor: writer, title: "映画の夏") }

  before { create(:studio_membership, studio:, writer:, role: :member) }

  describe "PATCH /studios/:studio_slug/zines/:zine_id/page_order" do
    let!(:first_page) { create(:page, zine:, title: "夏の名画座") }
    let!(:second_page) { create(:page, zine:, title: "秋の名画座") }
    let(:valid_params) { { page_ids: [ second_page.id, first_page.id ] } }

    context "ログインしていないとき" do
      it "ページを並べ替えない" do
        patch studio_zine_page_order_path(studio.slug, zine), params: valid_params

        expect(zine.pages.reload).to eq [ first_page, second_page ]
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "ページを渡した順に並べ替える" do
        patch studio_zine_page_order_path(studio.slug, zine), params: valid_params

        expect(zine.pages.reload).to eq [ second_page, first_page ]
      end

      it "303 でページの一覧にリダイレクトする" do
        patch studio_zine_page_order_path(studio.slug, zine), params: valid_params

        expect([ response.status, response.location ]).to eq [ 303, studio_zine_pages_url(studio.slug, zine) ]
      end
    end
  end
end
