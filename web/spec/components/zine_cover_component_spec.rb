require "rails_helper"

RSpec.describe ZineCoverComponent, type: :component do
  it "タイトルとスタジオ名を表示する" do
    studio = create(:studio, name: "映画好きの集まり", slug: "cinema01")
    zine = create(:zine, studio:, title: "映画の夏")

    html = render_inline(described_class.new(zine:))

    expect(html.text.squish).to eq "映画の夏 映画好きの集まり"
  end
end
