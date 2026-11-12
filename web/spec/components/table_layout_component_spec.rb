require "rails_helper"

RSpec.describe TableLayoutComponent, type: :component do
  it "content を表示する" do
    html = render_inline(described_class.new) { "表" }

    expect(html.at_css(".overflow-x-auto").text.squish).to eq "表"
  end

  describe "pagination" do
    it "ページが複数あると、次のページへのリンクを表示する" do
      create(:studio, name: "映画好きの集まり", slug: "cinema01")
      create(:studio, name: "シネマクラブ", slug: "cinema02")

      html = with_request_url("/admin/studios") do
        render_inline(described_class.new) do |layout|
          layout.with_pagination(Studio.order(:id).page(1).per(1))
          "表"
        end
      end

      expect(html.at_css("nav[aria-label='ページ送り'] a[href='/admin/studios?page=2']")).to be_present
    end
  end
end
