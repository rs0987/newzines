require "rails_helper"

RSpec.describe SelectFieldComponent, type: :component do
  def form_for(studio_membership)
    ActionView::Helpers::FormBuilder.new(:studio_membership, studio_membership, vc_test_controller.view_context, {})
  end

  it "属性のラベルと選択肢を表示する" do
    form = form_for(StudioMembership.new(role: :member))

    html = render_inline(described_class.new(form, :role, [ [ "メンバー", "member" ], [ "オーナー", "owner" ] ]))

    expect(html.at_css("label[for='studio_membership_role']").text).to eq "役割"
    expect(html.css("select#studio_membership_role option").map { |option| [ option.text, option["value"] ] }).to eq [ [ "メンバー", "member" ], [ "オーナー", "owner" ] ]
  end

  it "今の値を選んだ状態で表示する" do
    form = form_for(StudioMembership.new(role: :owner))

    html = render_inline(described_class.new(form, :role, [ [ "メンバー", "member" ], [ "オーナー", "owner" ] ]))

    expect(html.at_css("option[selected]").text).to eq "オーナー"
  end

  it "ラベルとヒント以外の引数を、選択欄に渡す" do
    form = form_for(StudioMembership.new(role: :member))

    html = render_inline(described_class.new(form, :role, [ [ "メンバー", "member" ] ], required: true))

    expect(html.at_css("select")["required"]).to eq "required"
  end

  it "渡した class を、標準の class に足す" do
    form = form_for(StudioMembership.new(role: :member))

    html = render_inline(described_class.new(form, :role, [ [ "メンバー", "member" ] ], class: "font-mono"))

    expect(html.at_css("select")["class"].split).to include("select", "font-mono")
  end

  it "ヒントを、選択欄から参照できるようにする" do
    form = form_for(StudioMembership.new(role: :member))

    html = render_inline(described_class.new(form, :role, [ [ "メンバー", "member" ] ], hint: "あとから変えられます。"))

    expect(html.at_css("select")["aria-describedby"]).to eq "studio_membership_role_hint"
  end
end
