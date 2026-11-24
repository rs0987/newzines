require "rails_helper"

RSpec.describe TrashIconComponent, type: :component do
  it "SVG を表示する" do
    html = render_inline(described_class.new)

    expect(html.at_css("svg")).to be_present
  end
end
