require "rails_helper"

RSpec.describe FormControlComponent, type: :component do
  def form_for(studio)
    ActionView::Helpers::FormBuilder.new(:studio, studio, vc_test_controller.view_context, {})
  end

  it "入力欄と結びついたラベルを表示する" do
    form = form_for(Studio.new(name: "", slug: ""))

    html = render_inline(described_class.new(form, :name, label: "スタジオ名")) { form.text_field(:name) }

    expect(html.at_css("label[for='studio_name']").text).to eq "スタジオ名"
  end

  it "content を入力欄として表示する" do
    form = form_for(Studio.new(name: "", slug: ""))

    html = render_inline(described_class.new(form, :name, label: "スタジオ名")) { form.text_field(:name) }

    expect(html.at_css("input#studio_name")).to be_present
  end
end
