require "rails_helper"

RSpec.describe ZineCardComponent, type: :component do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }

  it "タイトル・スタジオ名・説明を表示する" do
    zine = create(:zine, studio:, title: "映画の夏", description: "夏に観たい名作を紹介します")

    html = render_inline(described_class.new(zine:))

    expect(html.text.squish).to include("映画の夏 映画好きの集まり 夏に観たい名作を紹介します")
  end

  it "ZINE を読む画面へのリンクを表示する" do
    zine = create(:zine, studio:, title: "映画の夏")

    html = render_inline(described_class.new(zine:))

    expect(html.at_css("a[aria-label='映画の夏を読む']")["href"]).to eq "/zines/#{zine.id}"
  end
end
