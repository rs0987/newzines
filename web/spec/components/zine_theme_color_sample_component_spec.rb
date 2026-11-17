require "rails_helper"

RSpec.describe ZineThemeColorSampleComponent, type: :component do
  it "テーマカラーの名前と、見出し・本文・ノンブルの見本を、そのテーマカラーで表示する" do
    html = render_inline(described_class.new(theme_color: "abyss"))

    sample = html.at_css("[data-theme]")
    expect([ sample["data-theme"], sample.text.squish ]).to eq [ "abyss", "abyss 見出し 吾輩は猫である。名前はまだ無い。 - 1 -" ]
  end

  it "読み上げるのはテーマカラーの名前だけにする" do
    html = render_inline(described_class.new(theme_color: "abyss"))

    expect([ html.at_css(".sr-only").text, html.at_css("[data-theme]")["aria-hidden"] ]).to eq [ "abyss", "true" ]
  end
end
