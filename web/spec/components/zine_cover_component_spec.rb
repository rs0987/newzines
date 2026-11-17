require "rails_helper"

RSpec.describe ZineCoverComponent, type: :component do
  it "タイトルとスタジオ名を、ZINE のテーマカラーで表示する" do
    studio = create(:studio, name: "映画好きの集まり", slug: "cinema01")
    zine = create(:zine, studio:, title: "映画の夏", theme_color: "abyss")

    html = render_inline(described_class.new(zine:))

    cover = html.at_css("[data-theme]")
    expect([ cover["data-theme"], cover.text.squish ]).to eq [ "abyss", "映画の夏 映画好きの集まり" ]
  end
end
