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

  describe "GET /studios/:studio_slug/memberships/:id/edit" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        studio_membership = create(:studio_membership, studio:, role: :member)

        get edit_studio_membership_path(studio.slug, studio_membership)

        expect(response).to redirect_to(new_account_session_path)
      end
    end
  end

  describe "PATCH /studios/:studio_slug/memberships/:id" do
    let(:studio_membership) { create(:studio_membership, studio:, role: :member) }
    let(:valid_params) { { studio_membership: { role: "owner" } } }

    context "ログインしていないとき" do
      it "役割を変更しない" do
        patch studio_membership_path(studio.slug, studio_membership), params: valid_params

        expect(studio_membership.reload.role).to eq "member"
      end

      it "ログイン画面にリダイレクトする" do
        patch studio_membership_path(studio.slug, studio_membership), params: valid_params

        expect(response).to redirect_to(new_account_session_path)
      end
    end

    context "オーナーとしてログインしているとき" do
      before { sign_in create(:studio_membership, studio:, role: :owner).writer.account }

      it "役割を変更する" do
        patch studio_membership_path(studio.slug, studio_membership), params: valid_params

        expect(studio_membership.reload.role).to eq "owner"
      end

      it "303 でメンバー一覧にリダイレクトする" do
        patch studio_membership_path(studio.slug, studio_membership), params: valid_params

        expect([ response.status, response.location ]).to eq [ 303, studio_memberships_url(studio.slug) ]
      end
    end
  end
end
