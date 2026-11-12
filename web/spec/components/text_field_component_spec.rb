require "rails_helper"

RSpec.describe TextFieldComponent, type: :component do
  def form_for(studio)
    ActionView::Helpers::FormBuilder.new(:studio, studio, vc_test_controller.view_context, {})
  end

  it "属性のラベルと入力欄を表示する" do
    form = form_for(Studio.new(name: "", slug: ""))

    html = render_inline(described_class.new(form, :name))

    expect(html.at_css("label[for='studio_name']").text).to eq "スタジオ名"
    expect(html.at_css("input[type='text']#studio_name")).to be_present
  end

  it "ラベルとヒント以外の引数を、入力欄に渡す" do
    form = form_for(Studio.new(name: "", slug: ""))

    html = render_inline(described_class.new(form, :name, required: true, maxlength: 30))

    expect([ html.at_css("input")["required"], html.at_css("input")["maxlength"] ]).to eq [ "required", "30" ]
  end

  it "渡した class を、標準の class に足す" do
    form = form_for(Studio.new(name: "", slug: ""))

    html = render_inline(described_class.new(form, :name, class: "font-mono"))

    expect(html.at_css("input")["class"].split).to include("input", "font-mono")
  end

  it "ヒントとエラーを、入力欄から参照できるようにする" do
    studio = Studio.new(name: "", slug: "cinema01")
    studio.validate
    form = form_for(studio)

    html = render_inline(described_class.new(form, :name, hint: "30 文字まで。"))

    expect(html.at_css("input")["aria-describedby"]).to eq "studio_name_hint studio_name_error"
  end
end
