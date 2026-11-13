require "rails_helper"

RSpec.describe Writer, type: :model do
  let(:account) { create(:account) }

  it "アカウントがあれば有効である" do
    writer = build(:writer, account:)

    expect(writer).to be_valid
  end

  describe "account" do
    it "空なら無効である" do
      writer = build(:writer, account: nil)

      expect(writer).not_to be_valid
    end

    it "すでにライターを持っているなら無効である" do
      create(:writer, account:)
      writer = build(:writer, account:)

      expect(writer).not_to be_valid
    end
  end
end
