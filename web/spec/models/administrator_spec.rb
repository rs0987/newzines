require "rails_helper"

RSpec.describe Administrator, type: :model do
  it "username とパスワードだけで保存できる" do
    administrator = build(:administrator, username: "admin01", password: "password12345678")

    expect(administrator).to be_valid
  end

  describe "username" do
    it "空だと保存できない" do
      administrator = build(:administrator, username: "", password: "password12345678")

      expect(administrator).not_to be_valid
    end

    it "英小文字と数字以外を含むと保存できない" do
      administrator = build(:administrator, username: "admin-01", password: "password12345678")

      expect(administrator).not_to be_valid
    end

    it "大文字を含むと、小文字に変換して保存される" do
      administrator = create(:administrator, username: "Admin01", password: "password12345678")

      expect(administrator.reload.username).to eq "admin01"
    end

    it "小文字に変換すると既存のものと重複する場合、保存できない" do
      create(:administrator, username: "admin01", password: "password12345678")
      administrator = build(:administrator, username: "ADMIN01", password: "password12345678")

      expect(administrator).not_to be_valid
    end
  end

  describe "password" do
    it "空だと保存できない" do
      administrator = build(:administrator, username: "admin01", password: "")

      expect(administrator).not_to be_valid
    end

    it "16 文字なら保存できる" do
      administrator = build(:administrator, username: "admin01", password: "a" * 16)

      expect(administrator).to be_valid
    end

    it "15 文字だと保存できない" do
      administrator = build(:administrator, username: "admin01", password: "a" * 15)

      expect(administrator).not_to be_valid
    end
  end
end
