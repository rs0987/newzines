require "rails_helper"

RSpec.describe FieldsetComponent, type: :component do
  def form_for(zine)
    ActionView::Helpers::FormBuilder.new(:zine, zine, vc_test_controller.view_context, {})
  end

  it "legend を見出しとして、content をその下に表示する" do
    form = form_for(Zine.new(title: "映画の夏"))

    html = render_inline(described_class.new(form, :title, legend: "題名")) { "選択肢" }

    legend = html.at_css("fieldset > legend")
    expect([ legend.text, legend.next_sibling.text.squish ]).to eq [ "題名", "選択肢" ]
  end

  it "legend を渡さないと、属性名の翻訳を見出しにする" do
    form = form_for(Zine.new(title: "映画の夏"))

    html = render_inline(described_class.new(form, :title)) { "選択肢" }

    expect(html.at_css("fieldset > legend").text).to eq "タイトル"
  end

  describe "hint" do
    it "表示して、fieldset の説明として結びつける" do
      form = form_for(Zine.new(title: "映画の夏"))

      html = render_inline(described_class.new(form, :title, hint: "30 文字まで。")) { "選択肢" }

      expect([ html.at_css("fieldset")["aria-describedby"], html.at_css("#zine_title_hint").text ]).to eq [ "zine_title_hint", "30 文字まで。" ]
    end

    it "渡さないと表示しない" do
      form = form_for(Zine.new(title: "映画の夏"))

      html = render_inline(described_class.new(form, :title)) { "選択肢" }

      expect([ html.at_css("#zine_title_hint"), html.at_css("fieldset")["aria-describedby"] ]).to eq [ nil, nil ]
    end
  end

  describe "エラー" do
    it "その項目のエラーを表示して、fieldset の説明として結びつける" do
      zine = Zine.new(title: "")
      zine.validate
      form = form_for(zine)

      html = render_inline(described_class.new(form, :title)) { "選択肢" }

      expect([ html.at_css("fieldset")["aria-describedby"], html.at_css("#zine_title_error").text.squish ]).to eq [ "zine_title_error", "タイトルを入力してください" ]
    end
  end
end
