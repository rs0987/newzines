require "rails_helper"

RSpec.describe CardComponent, type: :component do
  it "title を見出しとして、content をその下に表示する" do
    html = render_inline(described_class.new(title: "基本情報")) { "本文" }

    expect(html.at_css("h2").text).to eq "基本情報"
    expect(html.at_css(".card-body").text.squish).to eq "基本情報 本文"
  end

  it "color に :error を渡すと、エラーの色で表示する" do
    html = render_inline(described_class.new(title: "危険な操作", color: :error)) { "本文" }

    expect([ html.at_css(".card")["class"].split, html.at_css("h2")["class"].split ].flatten).to include("card-border", "border-error/30", "text-error")
  end
end
