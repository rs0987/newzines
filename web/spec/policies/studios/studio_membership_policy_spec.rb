require "rails_helper"

RSpec.describe Studios::StudioMembershipPolicy do
  describe "Scope" do
    it "ログインしているアカウントのメンバーシップだけを返す" do
      writer = create(:writer)
      own_membership = create(:studio_membership, writer:)
      create(:studio_membership)

      studio_memberships = described_class::Scope.new(writer.account, StudioMembership).resolve

      expect(studio_memberships).to eq [ own_membership ]
    end

    it "ライターではないアカウントには何も返さない" do
      account = create(:account)
      create(:studio_membership)

      studio_memberships = described_class::Scope.new(account, StudioMembership).resolve

      expect(studio_memberships).to be_empty
    end
  end
end
