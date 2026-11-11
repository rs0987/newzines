require "rails_helper"

RSpec.describe Admin::ApplicationPolicy do
  context "閲覧者のとき" do
    it "一覧と詳細の表示を許可する" do
      administrator = build(:administrator, username: "admin01", password: "password12345678", role: :viewer)

      policy = described_class.new(administrator, :record)

      expect([ policy.index?, policy.show? ]).to eq [ true, true ]
    end

    it "作成・更新・削除を許可しない" do
      administrator = build(:administrator, username: "admin01", password: "password12345678", role: :viewer)

      policy = described_class.new(administrator, :record)

      expect([ policy.create?, policy.update?, policy.destroy? ]).to eq [ false, false, false ]
    end
  end

  context "編集者のとき" do
    it "作成・更新・削除を許可する" do
      administrator = build(:administrator, username: "admin01", password: "password12345678", role: :editor)

      policy = described_class.new(administrator, :record)

      expect([ policy.create?, policy.update?, policy.destroy? ]).to eq [ true, true, true ]
    end
  end
end
