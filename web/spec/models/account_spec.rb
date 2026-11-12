require "rails_helper"

RSpec.describe Account, type: :model do
  it "username とパスワードだけで保存できる" do
    account = build(:account, username: "writer01", password: "password12345678")

    expect(account).to be_valid
  end

  describe "username" do
    it "空だと保存できない" do
      account = build(:account, username: "", password: "password12345678")

      expect(account).not_to be_valid
    end

    it "30 文字なら保存できる" do
      account = build(:account, username: "a" * 30, password: "password12345678")

      expect(account).to be_valid
    end

    it "31 文字だと保存できない" do
      account = build(:account, username: "a" * 31, password: "password12345678")

      expect(account).not_to be_valid
    end

    it "英小文字と数字以外を含むと保存できない" do
      account = build(:account, username: "writer-01", password: "password12345678")

      expect(account).not_to be_valid
    end

    it "前後の空白が取り除かれ、小文字に変換されて保存される" do
      account = create(:account, username: " Writer01 ", password: "password12345678")

      expect(account.reload.username).to eq "writer01"
    end

    it "小文字に変換すると既存のものと重複する場合、保存できない" do
      create(:account, username: "writer01", password: "password12345678")
      account = build(:account, username: "WRITER01", password: "password12345678")

      expect(account).not_to be_valid
    end
  end

  describe "password" do
    it "空だと保存できない" do
      account = build(:account, username: "writer01", password: "")

      expect(account).not_to be_valid
    end

    it "16 文字なら保存できる" do
      account = build(:account, username: "writer01", password: "a" * 16)

      expect(account).to be_valid
    end

    it "15 文字だと保存できない" do
      account = build(:account, username: "writer01", password: "a" * 15)

      expect(account).not_to be_valid
    end
  end
end
