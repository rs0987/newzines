require "rails_helper"

RSpec.describe "スタジオサイトのメンバー", type: :request do
  let(:studio) { create(:studio) }
  let(:writer) { create(:writer, account: create(:account, username: "writer01")) }

  before { create(:studio_membership, studio:, writer:, role: :member) }

  describe "GET /studios/:studio_slug/memberships" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get studio_memberships_path(studio.slug)

        expect(response).to redirect_to(new_account_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      it "スタジオのメンバーのユーザー名と役割を表示する" do
        owner = create(:writer, account: create(:account, username: "owner01"))
        create(:studio_membership, studio:, writer: owner, role: :owner)
        outsider = create(:writer, account: create(:account, username: "outsider01"))
        create(:studio_membership, studio: create(:studio), writer: outsider, role: :owner)

        get studio_memberships_path(studio.slug)

        rows = Nokogiri::HTML(response.body).css("table#memberships tbody tr").map { |row| row.css("td").first(2).map { |cell| cell.text.squish } }
        expect(rows).to eq [ %w[writer01 メンバー], %w[owner01 オーナー] ]
      end
    end
  end
end
