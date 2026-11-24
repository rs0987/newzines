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

  describe "tab" do
    it "渡した順に、ネタ帳の下へリンクとして表示する" do
      html = render_inline(described_class.new) do |list|
        list.with_tab name: "一覧", path: "/studios/cinema01/ideas", color: :info, current: true
        list.with_tab name: "アーカイブ", path: "/studios/cinema01/ideas/archived", color: :warning
        "ネタの行"
      end

      links = html.css("nav[aria-label='タブの切り替え'] a").map { |link| [ link.text, link["href"] ] }
      expect(links).to eq [ [ "一覧", "/studios/cinema01/ideas" ], [ "アーカイブ", "/studios/cinema01/ideas/archived" ] ]
    end

    it "current を指定したタブを、今いるページとして示す" do
      html = render_inline(described_class.new) do |list|
        list.with_tab name: "一覧", path: "/studios/cinema01/ideas", color: :info, current: true
        list.with_tab name: "アーカイブ", path: "/studios/cinema01/ideas/archived", color: :warning
        "ネタの行"
      end

      expect(html.at_css("nav a[aria-current='page']").text).to eq "一覧"
    end

    it "用意していない色を指定すると、エラーを出す" do
      expect {
        render_inline(described_class.new) do |list|
          list.with_tab name: "一覧", path: "/studios/cinema01/ideas", color: :secondary
          "ネタの行"
        end
      }.to raise_error(KeyError)
    end
  end
end
