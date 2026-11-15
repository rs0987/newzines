require "rails_helper"

RSpec.describe Admin::ApplicationPolicy do
  permissions :index?, :show? do
    it "閲覧者には許可する" do
      expect(described_class).to permit(build(:administrator, role: :viewer), :record)
    end

    it "編集者には許可する" do
      expect(described_class).to permit(build(:administrator, role: :editor), :record)
    end
  end

  permissions :create?, :update?, :destroy? do
    it "閲覧者には許可しない" do
      expect(described_class).not_to permit(build(:administrator, role: :viewer), :record)
    end

    it "編集者には許可する" do
      expect(described_class).to permit(build(:administrator, role: :editor), :record)
    end
  end
end
