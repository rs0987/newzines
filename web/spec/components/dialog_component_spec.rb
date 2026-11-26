require "rails_helper"

RSpec.describe DialogComponent, type: :component do
  it "指定した id の dialog タグを描画する" do
    html = render_inline(described_class.new(id: "role-dialog", title: "役割の変更")) { "本文" }

    expect(html.at_css("dialog#role-dialog")).to be_present
  end
end
