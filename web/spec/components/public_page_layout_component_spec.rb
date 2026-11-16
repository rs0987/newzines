require "rails_helper"

RSpec.describe PublicPageLayoutComponent, type: :component do
  it "title を見出しとして表示する" do
    html = render_inline(described_class.new(title: "最近発行された ZINE")) { "本文" }

    expect(html.at_css("h1").text).to eq "最近発行された ZINE"
  end

  it "content を見出しの下に表示する" do
    html = render_inline(described_class.new(title: "最近発行された ZINE")) { "本文" }

    expect(html.at_css("h1").next_element.text.squish).to eq "本文"
  end
end
