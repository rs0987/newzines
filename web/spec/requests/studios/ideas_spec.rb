require "rails_helper"

RSpec.describe "スタジオサイトのネタ帳", type: :request do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }
  let(:writer) { create(:writer, account: create(:account, username: "writer01", password: "password12345678")) }
  let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html, text/html" } }

  before { create(:studio_membership, studio:, writer:, role: :member) }

  describe "GET /studios/:studio_slug/ideas" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get studio_ideas_path(studio.slug)

        expect(response).to redirect_to(new_account_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "アーカイブしていないネタだけを表示する" do
        create(:idea, studio:, writer:, title: "一覧のネタ")
        create(:idea, studio:, writer:, title: "アーカイブしたネタ", archived_at: Time.current)

        get studio_ideas_path(studio.slug)

        titles = Nokogiri::HTML(response.body).css("dl#ideas dt").map { |title| title.text.squish }
        expect(titles).to eq [ "一覧のネタ" ]
      end
    end
  end

  describe "POST /studios/:studio_slug/ideas" do
    context "ログインしていないとき" do
      it "ネタを作成しない" do
        expect {
          post studio_ideas_path(studio.slug), headers: turbo_stream_headers
        }.not_to change(Idea, :count)
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "ログイン中のライターが書いた、空のネタを作成する" do
        post studio_ideas_path(studio.slug), headers: turbo_stream_headers

        idea = studio.ideas.last
        expect([ idea.writer, idea.title, idea.body ]).to eq [ writer, nil, nil ]
      end

      it "タイトルを入力欄にした行を、Turbo Stream でリストの末尾に足す" do
        post studio_ideas_path(studio.slug), headers: turbo_stream_headers

        idea = studio.ideas.last
        stream = Nokogiri::HTML.fragment(response.body).at_css("turbo-stream[action='append'][target='ideas']")
        expect(stream.at_css("template textarea[name='idea[title]']")).to be_present
        expect(stream.at_css("template > div")["id"]).to eq "idea_#{idea.id}"
      end
    end
  end

  describe "GET /studios/:studio_slug/ideas/:id/edit" do
    let(:idea) { create(:idea, studio:, writer:, title: "夏の名画座") }

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "指定したフィールドの入力欄を表示する" do
        get edit_studio_idea_path(studio.slug, idea, field: "title")

        textarea = Nokogiri::HTML(response.body).at_css("turbo-frame#title_idea_#{idea.id} textarea[name='idea[title]']")
        expect(textarea.text.strip).to eq "夏の名画座"
      end

      it "編集できないフィールドなら 400 を返す" do
        get edit_studio_idea_path(studio.slug, idea, field: "writer_id")

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "PATCH /studios/:studio_slug/ideas/:id" do
    let(:idea) { create(:idea, studio:, writer:, title: "夏の名画座", body: "名画座の夏の特集を回る") }

    context "ログインしていないとき" do
      it "タイトルを更新しない" do
        patch studio_idea_path(studio.slug, idea, field: "title"), params: { idea: { title: "秋の名画座" } }, headers: turbo_stream_headers

        expect(idea.reload.title).to eq "夏の名画座"
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "指定したフィールドだけを更新する" do
        patch studio_idea_path(studio.slug, idea, field: "title"),
              params: { idea: { title: "秋の名画座", body: "書き換えない本文" } },
              headers: turbo_stream_headers

        idea.reload
        expect([ idea.title, idea.body ]).to eq [ "秋の名画座", "名画座の夏の特集を回る" ]
      end

      it "更新したセルを、Turbo Stream で表示に戻す" do
        patch studio_idea_path(studio.slug, idea, field: "title"), params: { idea: { title: "秋の名画座" } }, headers: turbo_stream_headers

        stream = Nokogiri::HTML.fragment(response.body).at_css("turbo-stream[action='replace'][target='title_idea_#{idea.id}']")
        expect(stream.at_css("template turbo-frame").text.squish).to eq "秋の名画座"
      end
    end
  end
end
