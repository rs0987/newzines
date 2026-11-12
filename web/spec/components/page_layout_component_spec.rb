require "rails_helper"

RSpec.describe PageLayoutComponent, type: :component do
  it "title を見出しとして表示する" do
    html = render_inline(described_class.new(title: "映画好きの集まり")) { "本文" }

    expect(html.at_css("h1").text).to eq "映画好きの集まり"
  end

  it "content を見出しの下に表示する" do
    html = render_inline(described_class.new(title: "映画好きの集まり")) { "本文" }

    expect(html.at_css("h1").next_element.text.squish).to eq "本文"
  end

  it "breadcrumb を渡した順に表示する" do
    html = render_inline(described_class.new(title: "映画好きの集まり")) do |page|
      page.with_breadcrumb("スタジオ一覧", "/admin/studios")
      page.with_breadcrumb("映画好きの集まり")
      "本文"
    end

    expect(html.css("nav li").map { |item| item.text.squish }).to eq [ "スタジオ一覧", "映画好きの集まり" ]
  end

  it "path を渡さない breadcrumb を、今のページとして示す" do
    html = render_inline(described_class.new(title: "映画好きの集まり")) do |page|
      page.with_breadcrumb("スタジオ一覧", "/admin/studios")
      page.with_breadcrumb("映画好きの集まり")
      "本文"
    end

    expect(html.at_css("nav [aria-current='page']").text).to eq "映画好きの集まり"
  end

  it "breadcrumb を渡さないと、パンくずを表示しない" do
    html = render_inline(described_class.new(title: "ダッシュボード")) { "本文" }

    expect(html.at_css("nav")).to be_nil
  end

  it "action を渡した順に表示する" do
    html = render_inline(described_class.new(title: "映画好きの集まり")) do |page|
      page.with_action { "編集" }
      page.with_action { "削除" }
      "本文"
    end

    page_header = html.at_css("h1").previous_element
    expect(page_header.text.squish).to eq "編集 削除"
  end
end
