require "rails_helper"

RSpec.describe IdeaListComponent, type: :component do
  it "content をリストの中に表示する" do
    html = render_inline(described_class.new) { "ネタの行" }

    expect(html.at_css("dl#ideas").text.squish).to eq "ネタの行"
  end

  describe "footer" do
    it "リストの下に表示する" do
      html = render_inline(described_class.new) do |list|
        list.with_footer { "追加ボタン" }
        "ネタの行"
      end

      expect(html.at_css("dl#ideas").next_element.text.squish).to eq "追加ボタン"
    end

    it "渡さないと、リストの下に何も表示しない" do
      html = render_inline(described_class.new) { "ネタの行" }

      expect(html.at_css("dl#ideas").next_element).to be_nil
    end
  end
end
