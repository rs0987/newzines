require "rails_helper"

RSpec.describe Studios::PagePolicy do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }
  let(:zine) { create(:zine, studio:, title: "映画の夏") }

  permissions :show? do
    it "スタジオのメンバーには許可する" do
      writer = create(:writer)
      create(:studio_membership, studio:, writer:, role: :member)

      expect(described_class).to permit(writer.account, build(:page, zine:, title: "夏の名画座"))
    end

    it "スタジオのメンバーではないライターには許可しない" do
      writer = create(:writer)
      create(:studio_membership, studio: create(:studio, name: "本の虫", slug: "books01"), writer:, role: :owner)

      expect(described_class).not_to permit(writer.account, build(:page, zine:, title: "夏の名画座"))
    end
  end

  permissions :create?, :update?, :destroy? do
    context "スタジオのメンバーのとき" do
      let(:writer) { create(:studio_membership, studio:, role: :member).writer }

      it "ZINE が未発行なら許可する" do
        zine.update!(published_at: nil)
        page = build(:page, zine:, title: "夏の名画座")

        expect(described_class).to permit(writer.account, page)
      end

      it "ZINE が発行済みなら許可しない" do
        zine.update!(published_at: Time.current)
        page = build(:page, zine:, title: "夏の名画座")

        expect(described_class).not_to permit(writer.account, page)
      end
    end

    context "スタジオのメンバーではないライターのとき" do
      let(:writer) { create(:studio_membership, studio: create(:studio, name: "本の虫", slug: "books01"), role: :owner).writer }

      it "ZINE が未発行でも許可しない" do
        zine.update!(published_at: nil)
        page = build(:page, zine:, title: "夏の名画座")

        expect(described_class).not_to permit(writer.account, page)
      end
    end
  end

  permissions :write?, :submit? do
    context "担当ライターのとき" do
      let(:writer) { create(:studio_membership, studio:, role: :member).writer }

      it "下書きなら許可する" do
        expect(described_class).to permit(writer.account, build(:page, zine:, writer:, title: "夏の名画座", status: :draft))
      end

      it "確認中なら許可しない" do
        expect(described_class).not_to permit(writer.account, build(:page, zine:, writer:, title: "夏の名画座", status: :reviewing))
      end
    end

    context "担当ではないスタジオのメンバーのとき" do
      let(:writer) { create(:studio_membership, studio:, role: :owner).writer }

      it "下書きでも許可しない" do
        expect(described_class).not_to permit(writer.account, build(:page, zine:, title: "夏の名画座", status: :draft))
      end
    end
  end

  permissions :confirm? do
    context "責任編集者のとき" do
      let(:editor) { zine.editor }

      context "担当ライターではないとき" do
        it "確認中なら許可する" do
          expect(described_class).to permit(editor.account, build(:page, zine:, title: "夏の名画座", status: :reviewing))
        end

        it "下書きなら許可しない" do
          expect(described_class).not_to permit(editor.account, build(:page, zine:, title: "夏の名画座", status: :draft))
        end
      end

      context "担当ライターを兼ねているとき" do
        it "下書きでも許可する" do
          expect(described_class).to permit(editor.account, build(:page, zine:, writer: editor, title: "夏の名画座", status: :draft))
        end
      end
    end

    context "責任編集者ではないスタジオのメンバーのとき" do
      let(:writer) { create(:studio_membership, studio:, role: :owner).writer }

      it "確認中でも許可しない" do
        expect(described_class).not_to permit(writer.account, build(:page, zine:, title: "夏の名画座", status: :reviewing))
      end
    end
  end

  permissions :send_back? do
    context "責任編集者のとき" do
      let(:editor) { zine.editor }

      it "確認中なら許可する" do
        expect(described_class).to permit(editor.account, build(:page, zine:, title: "夏の名画座", status: :reviewing))
      end

      it "確定なら許可する" do
        expect(described_class).to permit(editor.account, build(:page, zine:, title: "夏の名画座", status: :confirmed))
      end

      it "下書きなら許可しない" do
        expect(described_class).not_to permit(editor.account, build(:page, zine:, title: "夏の名画座", status: :draft))
      end

      it "ZINE が発行済みなら、確定でも許可しない" do
        zine.update!(published_at: Time.current)
        page = build(:page, zine:, title: "夏の名画座", status: :confirmed)

        expect(described_class).not_to permit(editor.account, page)
      end
    end

    context "責任編集者ではないスタジオのメンバーのとき" do
      let(:writer) { create(:studio_membership, studio:, role: :owner).writer }

      it "確認中でも許可しない" do
        expect(described_class).not_to permit(writer.account, build(:page, zine:, title: "夏の名画座", status: :reviewing))
      end
    end
  end

  describe "Scope" do
    it "所属しているスタジオの ZINE のページだけを返す" do
      writer = create(:writer)
      create(:studio_membership, studio:, writer:, role: :member)
      own_page = create(:page, zine:, title: "夏の名画座")
      create(:page, zine: create(:zine, studio: create(:studio, name: "本の虫", slug: "books01"), title: "読書の秋"), title: "秋の文庫本")

      pages = described_class::Scope.new(writer.account, Page).resolve

      expect(pages).to eq [ own_page ]
    end
  end
end
