require "rails_helper"

RSpec.describe FormLayoutComponent, type: :component do
  it "content をカードの中に表示する" do
    html = render_inline(described_class.new) { "入力欄" }

    expect(html.at_css(".card-body").text.squish).to eq "入力欄"
  end

  it "action を渡した順に表示する" do
    html = render_inline(described_class.new) do |layout|
      layout.with_action { "キャンセル" }
      layout.with_action { "保存" }
      "入力欄"
    end

    expect(html.at_css(".card-actions").text.split).to eq [ "キャンセル", "保存" ]
  end

  it "action を渡さないと、action の欄を表示しない" do
    html = render_inline(described_class.new) { "入力欄" }

    expect(html.at_css(".card-actions")).to be_nil
  end
end
