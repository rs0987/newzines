require "rails_helper"

RSpec.describe Studios::ZinePolicy do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }

  permissions :show?, :create?, :update?, :destroy? do
    it "スタジオのメンバーには許可する" do
      writer = create(:writer)
      create(:studio_membership, studio:, writer:, role: :member)

      expect(described_class).to permit(writer.account, build(:zine, studio:, editor: writer, title: "映画の夏"))
    end

    it "スタジオのメンバーではないライターには許可しない" do
      writer = create(:writer)
      create(:studio_membership, studio: create(:studio, name: "本の虫", slug: "books01"), writer:, role: :owner)

      expect(described_class).not_to permit(writer.account, build(:zine, studio:, title: "映画の夏"))
    end

    it "ライターではないアカウントには許可しない" do
      account = create(:account)

      expect(described_class).not_to permit(account, build(:zine, studio:, title: "映画の夏"))
    end
  end

  permissions :publish? do
    let(:zine) { create(:zine, studio:, title: "映画の夏") }

    context "責任編集者のとき" do
      let(:editor) { zine.editor }

      it "すべてのページが確定なら許可する" do
        create(:page, zine:, title: "夏の名画座", status: :confirmed)

        expect(described_class).to permit(editor.account, zine)
      end

      it "確定ではないページがあれば許可しない" do
        create(:page, zine:, title: "夏の名画座", status: :reviewing)

        expect(described_class).not_to permit(editor.account, zine)
      end

      it "発行済みなら許可しない" do
        create(:page, zine:, title: "夏の名画座", status: :confirmed)
        zine.update!(published_at: Time.current)

        expect(described_class).not_to permit(editor.account, zine)
      end
    end

    context "責任編集者ではないスタジオのメンバーのとき" do
      let(:writer) { create(:studio_membership, studio:, role: :owner).writer }

      it "すべてのページが確定でも許可しない" do
        create(:page, zine:, title: "夏の名画座", status: :confirmed)

        expect(described_class).not_to permit(writer.account, zine)
      end
    end
  end

  permissions :unpublish? do
    context "責任編集者のとき" do
      let(:editor) { create(:studio_membership, studio:, role: :member).writer }

      it "発行済みなら許可する" do
        expect(described_class).to permit(editor.account, build(:zine, studio:, editor:, title: "映画の夏", published_at: Time.current))
      end

      it "未発行なら許可しない" do
        expect(described_class).not_to permit(editor.account, build(:zine, studio:, editor:, title: "映画の夏", published_at: nil))
      end
    end

    context "責任編集者ではないスタジオのメンバーのとき" do
      let(:writer) { create(:studio_membership, studio:, role: :owner).writer }

      it "発行済みでも許可しない" do
        expect(described_class).not_to permit(writer.account, build(:zine, studio:, title: "映画の夏", published_at: Time.current))
      end
    end
  end

  describe "Scope" do
    it "所属しているスタジオの ZINE だけを返す" do
      writer = create(:writer)
      create(:studio_membership, studio:, writer:, role: :member)
      own_zine = create(:zine, studio:, editor: writer, title: "映画の夏")
      create(:zine, studio: create(:studio, name: "本の虫", slug: "books01"), title: "読書の秋")

      zines = described_class::Scope.new(writer.account, Zine).resolve

      expect(zines).to eq [ own_zine ]
    end

    it "ライターではないアカウントには何も返さない" do
      account = create(:account)
      create(:zine, studio:, title: "映画の夏")

      zines = described_class::Scope.new(account, Zine).resolve

      expect(zines).to be_empty
    end
  end
end
