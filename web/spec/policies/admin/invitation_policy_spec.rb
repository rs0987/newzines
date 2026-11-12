require "rails_helper"

RSpec.describe Admin::InvitationPolicy do
  describe "cancel?" do
    it "閲覧者には許可しない" do
      administrator = build(:administrator, username: "admin01", password: "password12345678", role: :viewer)

      policy = described_class.new(administrator, :record)

      expect(policy.cancel?).to be false
    end

    it "編集者には許可する" do
      administrator = build(:administrator, username: "admin01", password: "password12345678", role: :editor)

      policy = described_class.new(administrator, :record)

      expect(policy.cancel?).to be true
    end
  end
end
