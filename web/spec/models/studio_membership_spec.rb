require "rails_helper"

RSpec.describe StudioMembership, type: :model do
  let(:studio) { create(:studio) }
  let(:writer) { create(:writer) }

  describe "writer" do
    it "どこにも所属していないなら有効である" do
      studio_membership = build(:studio_membership, studio:, writer:)

      expect(studio_membership).to be_valid
    end

    it "別のスタジオにだけ所属しているなら有効である" do
      create(:studio_membership, studio: create(:studio), writer:)
      studio_membership = build(:studio_membership, studio:, writer:)

      expect(studio_membership).to be_valid
    end

    it "同じスタジオにすでに所属していると無効である" do
      create(:studio_membership, studio:, writer:)
      studio_membership = build(:studio_membership, studio:, writer:)

      expect(studio_membership).not_to be_valid
    end
  end
end
