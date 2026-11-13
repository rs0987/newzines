require "rails_helper"

RSpec.describe "スタジオサイトのトップ", type: :request do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }
  let(:writer) { create(:writer, account: create(:account, username: "writer01", password: "password12345678")) }

  describe "GET /studios/:studio_slug" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get studio_root_path(studio.slug)

        expect(response).to redirect_to(new_account_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      context "スタジオに所属しているとき" do
        before { create(:studio_membership, studio:, writer:, role: :owner) }

        it "メニューにスタジオ名を表示する" do
          get studio_root_path("cinema01")

          html = Nokogiri::HTML(response.body)
          expect(html.at_css("nav[aria-label='スタジオメニュー'] a[href='#{studio_root_path("cinema01")}']").text).to eq "映画好きの集まり"
        end
      end

      context "スタジオに所属していないとき" do
        before { create(:studio_membership, studio: create(:studio, name: "本の虫", slug: "books01"), writer:, role: :owner) }

        it "404 を返す" do
          get studio_root_path(studio.slug)

          expect(response).to have_http_status(:not_found)
        end
      end

      context "スタジオが存在しないとき" do
        it "404 を返す" do
          get studio_root_path("nothing01")

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "ライターではないアカウントでログインしているとき" do
      before { sign_in create(:account, username: "reader01", password: "password12345678") }

      it "404 を返す" do
        get studio_root_path(studio.slug)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
