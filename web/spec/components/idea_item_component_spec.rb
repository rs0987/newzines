require "rails_helper"

RSpec.describe IdeaItemComponent, type: :component do
  let(:studio) { create(:studio) }
  let(:writer) { create(:studio_membership, studio:).writer }

  it "タイトルと本文を表示する" do
    idea = create(:idea, studio:, writer:, title: "夏の名画座", body: "名画座の夏の特集を回る")

    html = render_inline(described_class.new(idea:))

    expect(html.text.squish).to eq "夏の名画座 名画座の夏の特集を回る"
  end

  describe "editing_field" do
    it "編集中のフィールドは入力欄で、そうでないフィールドはリンクで表示する" do
      idea = create(:idea, studio:, writer:, title: "夏の名画座", body: "名画座の夏の特集を回る")

      html = render_inline(described_class.new(idea:, editing_field: "title"))

      # 1 つ目のセルがタイトル、2 つ目のセルが本文
      cells = html.css("turbo-frame")
      expect(cells[0].at_css("textarea")).to be_present
      expect(cells[1].at_css("a")).to be_present
    end

    it "編集できないフィールドを指定すると、エラーを出す" do
      idea = create(:idea, studio:, writer:)

      expect { described_class.new(idea:, editing_field: "writer_id") }.to raise_error(ArgumentError)
    end
  end
end
