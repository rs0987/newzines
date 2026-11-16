require "rails_helper"

RSpec.describe "スタジオサイトの ZINE の発行", type: :request do
  let(:studio) { create(:studio) }
  let(:writer) { create(:writer) }
  let(:zine) { create(:zine, studio:, editor: writer, title: "映画の夏") }

  before { create(:studio_membership, studio:, writer:, role: :member) }

  describe "POST /studios/:studio_slug/zines/:zine_id/publication" do
    before { create(:page, zine:, title: "夏の名画座", status: :confirmed) }

    context "ログインしていないとき" do
      it "ZINE を発行しない" do
        post studio_zine_publication_path(studio.slug, zine)

        expect(zine.reload.published_at).to be_nil
      end
    end

    context "責任編集者としてログインしているとき" do
      before { sign_in writer.account }

      it "ZINE を発行する" do
        post studio_zine_publication_path(studio.slug, zine)

        expect(zine.reload.published_at).to be_present
      end

      it "303 で ZINE の詳細にリダイレクトする" do
        post studio_zine_publication_path(studio.slug, zine)

        expect([ response.status, response.location ]).to eq [ 303, studio_zine_url(studio.slug, zine) ]
      end
    end
  end
end
