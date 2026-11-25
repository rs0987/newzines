require "rails_helper"

RSpec.describe "スタジオサイトのネタ帳のアーカイブ", type: :request do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }
  let(:writer) { create(:writer, account: create(:account, username: "writer01")) }

  before { create(:studio_membership, studio:, writer:, role: :member) }

  describe "GET /studios/:studio_slug/ideas/archived" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get studio_archived_ideas_path(studio.slug)

        expect(response).to redirect_to(new_account_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "アーカイブしたネタだけを表示する" do
        create(:idea, studio:, writer:, title: "一覧のネタ")
        create(:idea, studio:, writer:, title: "アーカイブしたネタ", archived_at: Time.current)

        get studio_archived_ideas_path(studio.slug)

        titles = Nokogiri::HTML(response.body).css("dl#ideas dt").map { |title| title.text.squish }
        expect(titles).to eq [ "アーカイブしたネタ" ]
      end

      it "アーカイブしたネタが無ければ、無いことを表示する" do
        create(:idea, studio:, writer:, title: "一覧のネタ")

        get studio_archived_ideas_path(studio.slug)

        expect(response.body).to include("ネタがありません")
      end
    end
  end

  describe "DELETE /studios/:studio_slug/ideas/archived/:id" do
    context "ログインしていないとき" do
      it "ネタを削除しない" do
        idea = create(:idea, studio:, writer:, title: "夏の名画座", archived_at: Time.current)

        expect {
          delete studio_archived_idea_path(studio.slug, idea)
        }.not_to change(Idea, :count)
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "アーカイブしたネタを削除する" do
        idea = create(:idea, studio:, writer:, title: "夏の名画座", archived_at: Time.current)

        delete studio_archived_idea_path(studio.slug, idea)

        expect(Idea.exists?(idea.id)).to be false
      end

      it "303 でネタ帳のアーカイブにリダイレクトする" do
        idea = create(:idea, studio:, writer:, title: "夏の名画座", archived_at: Time.current)

        delete studio_archived_idea_path(studio.slug, idea)

        expect([ response.status, response.location ]).to eq [ 303, studio_archived_ideas_url(studio.slug) ]
      end

      it "アーカイブしていないネタなら、削除せずに 404 を返す" do
        idea = create(:idea, studio:, writer:, title: "夏の名画座")

        delete studio_archived_idea_path(studio.slug, idea)

        expect([ response.status, Idea.exists?(idea.id) ]).to eq [ 404, true ]
      end
    end
  end
end
