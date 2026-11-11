require "rails_helper"

RSpec.describe PageLayoutComponent, type: :component do
  it "title を見出しとして表示する" do
    html = render_inline(described_class.new(title: "スタジオ一覧")) { "本文" }

    expect(html.at_css("h1").text).to eq "スタジオ一覧"
  end

  it "content をページヘッダの下に表示する" do
    html = render_inline(described_class.new(title: "スタジオ一覧")) { "本文" }

    page_header = html.at_css("h1").parent
    expect(page_header.next_element.text.squish).to eq "本文"
  end

  it "action を渡した順に表示する" do
    html = render_inline(described_class.new(title: "スタジオ一覧")) do |page|
      page.with_action { "作成" }
      page.with_action { "書き出し" }
      "本文"
    end

    expect(html.at_css("h1 + div").text.squish).to eq "作成 書き出し"
  end
end
