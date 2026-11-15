require "rails_helper"

RSpec.describe TextAreaFieldComponent, type: :component do
  def form_for(zine)
    ActionView::Helpers::FormBuilder.new(:zine, zine, vc_test_controller.view_context, {})
  end

  it "属性のラベルと入力欄を表示する" do
    form = form_for(Zine.new(title: "映画の夏", description: ""))

    html = render_inline(described_class.new(form, :description))

    expect(html.at_css("label[for='zine_description']").text).to eq "紹介文"
    expect(html.at_css("textarea#zine_description")).to be_present
  end

  it "ラベルとヒント以外の引数を、入力欄に渡す" do
    form = form_for(Zine.new(title: "映画の夏", description: ""))

    html = render_inline(described_class.new(form, :description, maxlength: 200, rows: 4))

    expect([ html.at_css("textarea")["maxlength"], html.at_css("textarea")["rows"] ]).to eq [ "200", "4" ]
  end

  it "渡した class を、標準の class に足す" do
    form = form_for(Zine.new(title: "映画の夏", description: ""))

    html = render_inline(described_class.new(form, :description, class: "font-mono"))

    expect(html.at_css("textarea")["class"].split).to include("textarea", "font-mono")
  end

  it "ヒントとエラーを、入力欄から参照できるようにする" do
    zine = Zine.new(title: "映画の夏", description: "あ" * 201)
    zine.validate
    form = form_for(zine)

    html = render_inline(described_class.new(form, :description, hint: "200 文字まで。"))

    expect(html.at_css("textarea")["aria-describedby"]).to eq "zine_description_hint zine_description_error"
  end
end
