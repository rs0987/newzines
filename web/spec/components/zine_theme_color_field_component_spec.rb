require "rails_helper"

RSpec.describe ZineThemeColorFieldComponent, type: :component do
  def form_for(zine)
    ActionView::Helpers::FormBuilder.new(:zine, zine, vc_test_controller.view_context, {})
  end

  it "選べるテーマカラーを、それぞれ選択肢として表示する" do
    form = form_for(Zine.new(theme_color: "retro"))

    html = render_inline(described_class.new(form))

    expect(html.css("input[type='radio'][name='zine[theme_color]']").map { |radio| radio["value"] }).to eq Zine.theme_colors.keys
  end
end
