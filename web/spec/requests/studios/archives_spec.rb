require "rails_helper"

RSpec.describe "スタジオサイトのネタのアーカイブ", type: :request do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }
  let(:writer) { create(:writer, account: create(:account, username: "writer01", password: "password12345678")) }

  before { create(:studio_membership, studio:, writer:, role: :member) }

  describe "POST /studios/:studio_slug/ideas/:idea_id/archive" do
    let(:idea) { create(:idea, studio:, writer:, title: "夏の名画座") }

    context "ログインしていないとき" do
      it "ネタをアーカイブしない" do
        post studio_idea_archive_path(studio.slug, idea)

        expect(idea.reload.archived_at).to be_nil
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "ネタをアーカイブする" do
        post studio_idea_archive_path(studio.slug, idea)

        expect(idea.reload.archived_at).to be_present
      end

      it "303 でネタ帳の一覧にリダイレクトする" do
        post studio_idea_archive_path(studio.slug, idea)

        expect([ response.status, response.location ]).to eq [ 303, studio_ideas_url(studio.slug) ]
      end
    end
  end

  describe "DELETE /studios/:studio_slug/ideas/:idea_id/archive" do
    let(:idea) { create(:idea, studio:, writer:, title: "夏の名画座", archived_at: Time.current) }

    context "ログインしていないとき" do
      it "ネタを一覧に戻さない" do
        delete studio_idea_archive_path(studio.slug, idea)

        expect(idea.reload.archived_at).to be_present
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "ネタを一覧に戻す" do
        delete studio_idea_archive_path(studio.slug, idea)

        expect(idea.reload.archived_at).to be_nil
      end

      it "303 でネタ帳のアーカイブにリダイレクトする" do
        delete studio_idea_archive_path(studio.slug, idea)

        expect([ response.status, response.location ]).to eq [ 303, studio_archived_ideas_url(studio.slug) ]
      end
    end
  end
end
