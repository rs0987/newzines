require "rails_helper"

RSpec.describe Studio, type: :model do
  it "name と slug があれば有効である" do
    studio = build(:studio, name: "映画好きの集まり", slug: "cinema01")

    expect(studio).to be_valid
  end

  describe "name" do
    it "空なら無効である" do
      studio = build(:studio, name: "", slug: "cinema01")

      expect(studio).not_to be_valid
    end

    it "30 文字なら有効である" do
      studio = build(:studio, name: "あ" * 30, slug: "cinema01")

      expect(studio).to be_valid
    end

    it "31 文字なら無効である" do
      studio = build(:studio, name: "あ" * 31, slug: "cinema01")

      expect(studio).not_to be_valid
    end
  end

  describe "slug" do
    it "空なら無効である" do
      studio = build(:studio, name: "映画好きの集まり", slug: "")

      expect(studio).not_to be_valid
    end

    it "30 文字なら有効である" do
      studio = build(:studio, name: "映画好きの集まり", slug: "a" * 30)

      expect(studio).to be_valid
    end

    it "31 文字なら無効である" do
      studio = build(:studio, name: "映画好きの集まり", slug: "a" * 31)

      expect(studio).not_to be_valid
    end

    it "英小文字と数字以外が含まれると無効である" do
      studio = build(:studio, name: "映画好きの集まり", slug: "cinema-01")

      expect(studio).not_to be_valid
    end

    it "前後の空白が取り除かれ、小文字に変換されて保存される" do
      studio = create(:studio, name: "映画好きの集まり", slug: " Cinema01 ")

      expect(studio.reload.slug).to eq "cinema01"
    end

    it "大文字・小文字を区別せずに既存のものと重複すると無効である" do
      create(:studio, name: "映画好きの集まり", slug: "cinema01")
      studio = build(:studio, name: "シネマクラブ", slug: "CINEMA01")

      expect(studio).not_to be_valid
    end

    it "作成後に変更しようとするとエラーになる" do
      studio = create(:studio, name: "映画好きの集まり", slug: "cinema01")

      expect { studio.update(slug: "movie01") }.to raise_error(ActiveRecord::ReadonlyAttributeError)
    end
  end
end
