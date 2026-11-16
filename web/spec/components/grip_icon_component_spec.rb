require "rails_helper"

RSpec.describe GripIconComponent, type: :component do
  it "縦 3 つ・横 2 つの点を、読み上げない SVG で表示する" do
    html = render_inline(described_class.new)

    expect([ html.css("svg circle").size, html.at_css("svg")["aria-hidden"] ]).to eq [ 6, "true" ]
  end
end
