require "rails_helper"

RSpec.describe Studios::InvitationPolicy do
  let(:studio) { create(:studio) }

  permissions :new?, :create?, :cancel? do
    it "スタジオのオーナーには許可する" do
      writer = create(:studio_membership, studio:, role: :owner).writer

      expect(described_class).to permit(writer.account, build(:invitation, studio:))
    end

    it "スタジオのメンバーには許可しない" do
      writer = create(:studio_membership, studio:, role: :member).writer

      expect(described_class).not_to permit(writer.account, build(:invitation, studio:))
    end

    it "ほかのスタジオのオーナーには許可しない" do
      writer = create(:studio_membership, studio: create(:studio), role: :owner).writer

      expect(described_class).not_to permit(writer.account, build(:invitation, studio:))
    end
  end

  describe "Scope" do
    it "自分が所属するスタジオの招待だけを返す" do
      writer = create(:studio_membership, studio:, role: :member).writer
      create(:invitation, studio:, username: "writer01")
      create(:invitation, studio: create(:studio), username: "writer02")

      invitations = described_class::Scope.new(writer.account, Invitation).resolve

      expect(invitations.map(&:username)).to eq [ "writer01" ]
    end
  end
end
