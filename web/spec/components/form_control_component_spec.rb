require "rails_helper"

RSpec.describe FormControlComponent, type: :component do
  def form_for(studio)
    ActionView::Helpers::FormBuilder.new(:studio, studio, vc_test_controller.view_context, {})
  end

  it "入力欄と結びついたラベルを表示する" do
    form = form_for(Studio.new(name: "", slug: ""))

    html = render_inline(described_class.new(form, :name, label: "スタジオの名前")) { form.text_field(:name) }

    expect(html.at_css("label[for='studio_name']").text).to eq "スタジオの名前"
  end

  it "label を渡さないと、属性名の翻訳をラベルにする" do
    form = form_for(Studio.new(name: "", slug: ""))

    html = render_inline(described_class.new(form, :name)) { form.text_field(:name) }

    expect(html.at_css("label[for='studio_name']").text).to eq "スタジオ名"
  end

  it "content を入力欄として表示する" do
    form = form_for(Studio.new(name: "", slug: ""))

    html = render_inline(described_class.new(form, :name, label: "スタジオ名")) { form.text_field(:name) }

    expect(html.at_css("input#studio_name")).to be_present
  end

  describe "hint" do
    it "入力欄から参照できるように表示する" do
      form = form_for(Studio.new(name: "", slug: ""))

      html = render_inline(described_class.new(form, :slug, label: "slug", hint: "英小文字と数字のみ")) do |control|
        form.text_field(:slug, aria: control.aria)
      end

      expect(html.at_css("input")["aria-describedby"]).to eq "studio_slug_hint"
      expect(html.at_css("#studio_slug_hint").text.squish).to eq "英小文字と数字のみ"
    end

    it "渡さないと表示しない" do
      form = form_for(Studio.new(name: "", slug: ""))

      html = render_inline(described_class.new(form, :slug, label: "slug")) { form.text_field(:slug) }

      expect(html.at_css("#studio_slug_hint")).to be_nil
    end
  end

  describe "エラー" do
    it "その項目のエラーを、入力欄から参照できるように表示する" do
      studio = Studio.new(name: "", slug: "cinema01")
      studio.validate
      form = form_for(studio)

      html = render_inline(described_class.new(form, :name, label: "スタジオ名")) do |control|
        form.text_field(:name, aria: control.aria)
      end

      expect(html.at_css("input")["aria-describedby"]).to eq "studio_name_error"
      expect(html.at_css("#studio_name_error").text.squish).to eq "スタジオ名を入力してください"
    end

    it "エラーがあると、入力欄を無効な値として示す" do
      studio = Studio.new(name: "", slug: "cinema01")
      studio.validate
      form = form_for(studio)

      html = render_inline(described_class.new(form, :name, label: "スタジオ名")) do |control|
        form.text_field(:name, aria: control.aria)
      end

      expect(html.at_css("input")["aria-invalid"]).to eq "true"
    end

    it "エラーがないと、表示しない" do
      studio = Studio.new(name: "映画好きの集まり", slug: "cinema01")
      studio.validate
      form = form_for(studio)

      html = render_inline(described_class.new(form, :name, label: "スタジオ名")) do |control|
        form.text_field(:name, aria: control.aria)
      end

      expect([ html.at_css("#studio_name_error"), html.at_css("input")["aria-invalid"] ]).to eq [ nil, nil ]
    end
  end
end
