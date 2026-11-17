require "rails_helper"

RSpec.describe PublicPageLayoutComponent, type: :component do
  it "title を見出しとして表示する" do
    html = render_inline(described_class.new(title: "ホーム")) { "本文" }

    expect(html.at_css("h1").text).to eq "ホーム"
  end

  it "content を見出しの下に表示する" do
    html = render_inline(described_class.new(title: "ホーム")) { "本文" }

    expect(html.at_css("h1").next_element.text.squish).to eq "本文"
  end

  it "back を渡すと、そこへ戻るリンクを表示する" do
    html = render_inline(described_class.new(title: "映画の夏")) do |page|
      page.with_back("ホーム", "/")
      "本文"
    end

    link = html.at_css("a")
    expect([ link["href"], link.text.squish ]).to eq [ "/", "‹ ホームに戻る" ]
  end

  it "back を渡さなければ、戻るリンクを表示しない" do
    html = render_inline(described_class.new(title: "ホーム")) { "本文" }

    expect(html.at_css("a")).to be_nil
  end

  it "description を表示する" do
    html = render_inline(described_class.new(title: "映画の夏")) do |page|
      page.with_description { "夏に観たい名作を紹介します" }
      "本文"
    end

    expect(html.text).to include "夏に観たい名作を紹介します"
  end
end
