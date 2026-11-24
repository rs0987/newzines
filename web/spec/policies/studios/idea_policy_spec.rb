require "rails_helper"

RSpec.describe Studios::IdeaPolicy do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }

  permissions :create?, :update?, :destroy? do
    it "スタジオのメンバーには許可する" do
      writer = create(:studio_membership, studio:, role: :member).writer

      expect(described_class).to permit(writer.account, build(:idea, studio:, writer:))
    end

    it "スタジオのメンバーではないライターには許可しない" do
      writer = create(:studio_membership, studio: create(:studio, name: "本の虫", slug: "books01"), role: :owner).writer

      expect(described_class).not_to permit(writer.account, build(:idea, studio:))
    end
  end

  describe "Scope" do
    it "自分が所属するスタジオのネタだけを返す" do
      writer = create(:studio_membership, studio:, role: :member).writer
      create(:idea, studio:, title: "所属するスタジオのネタ")
      create(:idea, studio: create(:studio, name: "本の虫", slug: "books01"), title: "所属しないスタジオのネタ")

      ideas = described_class::Scope.new(writer.account, Idea).resolve

      expect(ideas.map(&:title)).to eq [ "所属するスタジオのネタ" ]
    end
  end
end
