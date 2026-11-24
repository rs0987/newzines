require "rails_helper"

RSpec.describe ArchivedIdeaItemComponent, type: :component do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }
  let(:writer) { create(:studio_membership, studio:).writer }

  it "タイトルと本文を表示する" do
    idea = create(:idea, studio:, writer:, title: "夏の名画座", body: "名画座の夏の特集を回る", archived_at: Time.current)

    html = render_inline(described_class.new(idea:))

    expect(html.text.squish).to eq "夏の名画座 名画座の夏の特集を回る"
  end

  it "一覧に戻すボタンと、削除するボタンを表示する" do
    idea = create(:idea, studio:, writer:, title: "夏の名画座", archived_at: Time.current)

    html = render_inline(described_class.new(idea:))

    forms = html.css("form").map { |form| [ form.at_css("button")["aria-label"], form["action"], form.at_css("input[name='_method']")["value"] ] }
    expect(forms).to eq [
      [ "一覧に戻す", "/studios/cinema01/ideas/#{idea.id}/archive", "delete" ],
      [ "削除", "/studios/cinema01/ideas/archived/#{idea.id}", "delete" ]
    ]
  end
end
