require "rails_helper"

RSpec.describe InvitationStatusBadgeComponent, type: :component do
  it "受諾待ちを情報の色のバッジで表示する" do
    html = render_inline(described_class.new(status: :pending))

    expect([ html.at_css(".badge").text, html.at_css(".badge")["class"].split ]).to eq [ "受諾待ち", %w[badge badge-info] ]
  end

  it "受諾済みを成功の色のバッジで表示する" do
    html = render_inline(described_class.new(status: :accepted))

    expect([ html.at_css(".badge").text, html.at_css(".badge")["class"].split ]).to eq [ "受諾済み", %w[badge badge-success] ]
  end

  it "キャンセル済みを中立の色のバッジで表示する" do
    html = render_inline(described_class.new(status: :canceled))

    expect([ html.at_css(".badge").text, html.at_css(".badge")["class"].split ]).to eq [ "キャンセル済み", %w[badge badge-neutral] ]
  end

  it "期限切れを警告の色のバッジで表示する" do
    html = render_inline(described_class.new(status: :expired))

    expect([ html.at_css(".badge").text, html.at_css(".badge")["class"].split ]).to eq [ "期限切れ", %w[badge badge-warning] ]
  end
end
