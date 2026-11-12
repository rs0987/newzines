require "rails_helper"

RSpec.describe DescriptionListComponent, type: :component do
  it "item を、項目名と値の組として渡した順に表示する" do
    html = render_inline(described_class.new) do |list|
      list.with_item("slug") { "cinema01" }
      list.with_item("作成日時") { "2026/11/12 11:31" }
    end

    pairs = html.css("dl > div").map { |item| [ item.at_css("dt").text, item.at_css("dd").text ] }
    expect(pairs).to eq [ [ "slug", "cinema01" ], [ "作成日時", "2026/11/12 11:31" ] ]
  end
end
