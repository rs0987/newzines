require "rails_helper"

RSpec.describe Invitation, type: :model do
  let(:studio) { create(:studio) }
  let(:inviter) { create(:administrator) }

  it "スタジオ・招待者・username があれば有効である" do
    invitation = build(:invitation, studio:, inviter:, username: "writer01")

    expect(invitation).to be_valid
  end

  describe "username" do
    it "空なら無効である" do
      invitation = build(:invitation, studio:, inviter:, username: "")

      expect(invitation).not_to be_valid
    end

    it "30 文字なら有効である" do
      invitation = build(:invitation, studio:, inviter:, username: "a" * 30)

      expect(invitation).to be_valid
    end

    it "31 文字なら無効である" do
      invitation = build(:invitation, studio:, inviter:, username: "a" * 31)

      expect(invitation).not_to be_valid
    end

    it "英小文字と数字以外が含まれると無効である" do
      invitation = build(:invitation, studio:, inviter:, username: "writer-01")

      expect(invitation).not_to be_valid
    end

    it "前後の空白が取り除かれ、小文字に変換されて保存される" do
      invitation = create(:invitation, studio:, inviter:, username: " Writer01 ")

      expect(invitation.reload.username).to eq "writer01"
    end

    it "受諾待ちの招待と重複すると無効である" do
      create(:invitation, studio:, inviter:, username: "writer01")
      invitation = build(:invitation, studio:, inviter:, username: "writer01")

      expect(invitation).not_to be_valid
    end

    it "別のスタジオの受諾待ちの招待と重複しても無効である" do
      create(:invitation, studio: create(:studio), inviter:, username: "writer01")
      invitation = build(:invitation, studio:, inviter:, username: "writer01")

      expect(invitation).not_to be_valid
    end

    it "受諾済みの招待と重複すると無効である" do
      create(:invitation, studio:, inviter:, username: "writer01", accepted_at: Time.current)
      invitation = build(:invitation, studio:, inviter:, username: "writer01")

      expect(invitation).not_to be_valid
    end

    it "キャンセル済みの招待となら重複しても有効である" do
      create(:invitation, studio:, inviter:, username: "writer01", canceled_at: Time.current)
      invitation = build(:invitation, studio:, inviter:, username: "writer01")

      expect(invitation).to be_valid
    end

    it "期限切れの招待となら重複しても有効である" do
      travel_to 8.days.ago do
        create(:invitation, studio:, inviter:, username: "writer01")
      end
      invitation = build(:invitation, studio:, inviter:, username: "writer01")

      expect(invitation).to be_valid
    end
  end

  describe "token" do
    it "作成すると発行され、そのトークンで検索できる" do
      invitation = create(:invitation, studio:, inviter:, username: "writer01")

      expect(Invitation.find_by_token(invitation.token)).to eq invitation
    end

    it "保存されないため、読み込み直すと参照できない" do
      invitation = create(:invitation, studio:, inviter:, username: "writer01")

      expect(Invitation.find(invitation.id).token).to be_nil
    end
  end

  describe "expires_at" do
    it "作成から 7 日後になる" do
      travel_to Time.zone.local(2026, 11, 12, 10, 0, 0) do
        invitation = create(:invitation, studio:, inviter:, username: "writer01")

        expect(invitation.expires_at).to eq Time.zone.local(2026, 11, 19, 10, 0, 0)
      end
    end
  end
end
