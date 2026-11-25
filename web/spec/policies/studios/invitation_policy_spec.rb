require "rails_helper"

RSpec.describe Studios::InvitationPolicy do
  let(:studio) { create(:studio) }

  permissions :new?, :create? do
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
end
