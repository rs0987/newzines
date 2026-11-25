require "rails_helper"

RSpec.describe Studios::StudioMembershipPolicy do
  describe "Scope" do
    it "自分が所属するスタジオのメンバーシップだけを返す" do
      studio = create(:studio, name: "映画好きの集まり", slug: "cinema01")
      writer = create(:writer)
      own_membership = create(:studio_membership, studio:, writer:, role: :member)
      other_membership = create(:studio_membership, studio:, role: :owner)
      create(:studio_membership, studio: create(:studio, name: "本の虫", slug: "books01"), role: :owner)

      studio_memberships = described_class::Scope.new(writer.account, StudioMembership).resolve

      expect(studio_memberships).to contain_exactly(own_membership, other_membership)
    end

    it "ライターではないアカウントには何も返さない" do
      account = create(:account)
      create(:studio_membership)

      studio_memberships = described_class::Scope.new(account, StudioMembership).resolve

      expect(studio_memberships).to be_empty
    end
  end
end
