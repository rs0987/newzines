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

  describe "inviter" do
    it "管理者を入れると、招待者（管理者）として保存される" do
      administrator = create(:administrator)
      invitation = create(:invitation, inviter: administrator)

      expect(invitation.reload.inviter_administrator).to eq administrator
    end

    it "ライターを入れると、招待者（ライター）として保存される" do
      writer = create(:writer)
      invitation = create(:invitation, inviter: writer)

      expect(invitation.reload.inviter_writer).to eq writer
    end

    it "空なら無効である" do
      invitation = build(:invitation, inviter: nil)

      expect(invitation).not_to be_valid
    end
  end

  describe "role" do
    it "指定しなければメンバーになる" do
      invitation = Invitation.new

      expect(invitation.role).to eq "member"
    end

    it "空なら無効である" do
      invitation = build(:invitation, role: nil)

      expect(invitation).not_to be_valid
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

  describe "#status" do
    it "受諾もキャンセルもされず、期限内なら受諾待ちを返す" do
      invitation = create(:invitation, studio:, inviter:, username: "writer01")

      expect(invitation.status).to eq :pending
    end

    it "受諾されていれば受諾済みを返す" do
      invitation = create(:invitation, studio:, inviter:, username: "writer01", accepted_at: Time.current)

      expect(invitation.status).to eq :accepted
    end

    it "キャンセルされていればキャンセル済みを返す" do
      invitation = create(:invitation, studio:, inviter:, username: "writer01", canceled_at: Time.current)

      expect(invitation.status).to eq :canceled
    end

    it "期限を過ぎていれば期限切れを返す" do
      invitation = travel_to(8.days.ago) { create(:invitation, studio:, inviter:, username: "writer01") }

      expect(invitation.status).to eq :expired
    end
  end

  describe "#cancel!" do
    it "キャンセル日時を記録する" do
      invitation = create(:invitation, studio:, inviter:, username: "writer01")

      travel_to Time.zone.local(2026, 11, 12, 10, 0, 0) do
        invitation.cancel!
      end

      expect(invitation.reload.canceled_at).to eq Time.zone.local(2026, 11, 12, 10, 0, 0)
    end
  end

  describe "#accept" do
    context "パスワードが正しいとき" do
      it "招待のユーザー名でアカウントを作る" do
        invitation = create(:invitation, studio:, inviter:, username: "writer01")

        account = invitation.accept(password: "password12345678")

        expect(account).to have_attributes(persisted?: true, username: "writer01")
      end

      it "作ったアカウントを、ライターとして招待の役割でスタジオに所属させる" do
        invitation = create(:invitation, studio:, inviter:, username: "writer01", role: :member)

        account = invitation.accept(password: "password12345678")

        studio_membership = account.writer.studio_memberships.sole
        expect(studio_membership).to have_attributes(studio:, role: "member")
      end

      it "招待を受諾済みにする" do
        invitation = create(:invitation, studio:, inviter:, username: "writer01")

        invitation.accept(password: "password12345678")

        expect(invitation.reload.status).to eq :accepted
      end
    end

    context "パスワードが短いとき" do
      it "パスワードが短すぎるというエラーとともに、保存していないアカウントを返す" do
        invitation = create(:invitation, studio:, inviter:, username: "writer01")

        account = invitation.accept(password: "a" * 15)

        expect([ account.persisted?, account.errors.of_kind?(:password, :too_short) ]).to eq [ false, true ]
      end

      it "招待を受諾待ちのままにする" do
        invitation = create(:invitation, studio:, inviter:, username: "writer01")

        invitation.accept(password: "a" * 15)

        expect(invitation.reload.status).to eq :pending
      end
    end

    context "受諾待ちではないとき" do
      it "例外を発生させる" do
        invitation = create(:invitation, studio:, inviter:, username: "writer01", canceled_at: Time.current)

        expect {
          invitation.accept(password: "password12345678")
        }.to raise_error(Invitation::NotPendingError)
      end
    end
  end
end
