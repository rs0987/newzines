require "rails_helper"

RSpec.describe ZineCoverComponent, type: :component do
  it "title と studio_name を表示する" do
    html = render_inline(described_class.new(title: "映画の夏", studio_name: "映画好きの集まり"))

    expect(html.text.squish).to eq "映画の夏 映画好きの集まり"
  end
end
