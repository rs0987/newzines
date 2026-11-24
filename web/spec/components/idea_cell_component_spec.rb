require "rails_helper"

RSpec.describe IdeaCellComponent, type: :component do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }
  let(:writer) { create(:studio_membership, studio:).writer }

  context "編集していないとき" do
    it "編集画面へのリンクを表示する" do
      idea = create(:idea, studio:, writer:, title: "夏の名画座")

      html = render_inline(described_class.new(idea:, field: "title"))

      link = html.at_css("turbo-frame#title_idea_#{idea.id} a")
      expect([ link.text.squish, link["href"] ]).to eq [ "夏の名画座", "/studios/cinema01/ideas/#{idea.id}/edit?field=title" ]
    end

    it "ネタの指定したフィールドが空なら、何のフィールドかを表示する" do
      idea = create(:idea, studio:, writer:, body: nil)

      html = render_inline(described_class.new(idea:, field: "body"))

      expect(html.at_css("a").text.squish).to eq "本文"
    end
  end

  it "編集できないフィールドを指定すると、エラーを出す" do
    idea = create(:idea, studio:, writer:)

    expect { described_class.new(idea:, field: "writer_id") }.to raise_error(ArgumentError)
  end

  context "編集しているとき" do
    it "フィールドの値を入れた textarea を表示する" do
      idea = create(:idea, studio:, writer:, title: "夏の名画座")

      html = render_inline(described_class.new(idea:, field: "title", editing: true))

      textarea = html.at_css("turbo-frame#title_idea_#{idea.id} form textarea[name='idea[title]']")
      expect(textarea.text.strip).to eq "夏の名画座"
    end

    it "フォームの action を、指定したフィールドを更新する URL にする" do
      idea = create(:idea, studio:, writer:, title: "夏の名画座")

      html = render_inline(described_class.new(idea:, field: "title", editing: true))

      expect(html.at_css("form")["action"]).to eq "/studios/cinema01/ideas/#{idea.id}?field=title"
    end
  end
end
