require "rails_helper"

RSpec.describe ZinePageComponent, type: :component do
  it "タイトル・担当ライター・本文・ノンブルを表示する" do
    writer = create(:writer, account: create(:account, username: "writer01"))
    zine = create(:zine, title: "映画の夏")
    create(:studio_membership, studio: zine.studio, writer:)
    page = create(:page, zine:, writer:, title: "夏の名画座", body: "夏に観たい一本")

    html = render_inline(described_class.new(page:, number: 1))

    expect(html.text.squish).to eq "夏の名画座 writer01 夏に観たい一本 - 1 -"
  end
end
