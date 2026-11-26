require "rails_helper"

RSpec.describe Studios::StudioMembershipPolicy do
  permissions :edit?, :update? do
    let(:studio) { create(:studio) }

    context "スタジオのオーナーのとき" do
      let(:writer) { create(:studio_membership, studio:, role: :owner).writer }

      it "対象がほかのメンバーなら許可する" do
        studio_membership = create(:studio_membership, studio:, role: :member)

        expect(described_class).to permit(writer.account, studio_membership)
      end

      it "対象が自分なら許可しない" do
        studio_membership = writer.studio_memberships.find_by!(studio:)

        expect(described_class).not_to permit(writer.account, studio_membership)
      end
    end

    context "スタジオのメンバーのとき" do
      let(:writer) { create(:studio_membership, studio:, role: :member).writer }

      it "対象がほかのメンバーでも許可しない" do
        studio_membership = create(:studio_membership, studio:, role: :member)

        expect(described_class).not_to permit(writer.account, studio_membership)
      end
    end

    context "ほかのスタジオのオーナーのとき" do
      let(:writer) { create(:studio_membership, studio: create(:studio), role: :owner).writer }

      it "許可しない" do
        studio_membership = create(:studio_membership, studio:, role: :member)

        expect(described_class).not_to permit(writer.account, studio_membership)
      end
    end
  end

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
