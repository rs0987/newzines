require "rails_helper"

RSpec.describe "スタジオサイトのメンバー招待", type: :request do
  let(:studio) { create(:studio) }
  let(:writer) { create(:writer) }

  before { create(:studio_membership, studio:, writer:, role: :owner) }

  describe "GET /studios/:studio_slug/invitations/new" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get new_studio_invitation_path(studio.slug)

        expect(response).to redirect_to(new_account_session_path)
      end
    end
  end

  describe "POST /studios/:studio_slug/invitations" do
    let(:valid_params) { { invitation: { username: "writer02" } } }

    context "ログインしていないとき" do
      it "招待を作成しない" do
        expect {
          post studio_invitations_path(studio.slug), params: valid_params
        }.not_to change(Invitation, :count)
      end

      it "ログイン画面にリダイレクトする" do
        post studio_invitations_path(studio.slug), params: valid_params

        expect(response).to redirect_to(new_account_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in writer.account }

      context "入力が正しいとき" do
        it "ログイン中のライターを招待者として、スタジオのメンバーへの招待を作成する" do
          post studio_invitations_path(studio.slug), params: valid_params

          invitation = Invitation.last
          expect(invitation).to have_attributes(studio:, username: "writer02", inviter: writer, role: "member")
        end

        it "招待 URL をコピーできる画面を表示する" do
          post studio_invitations_path(studio.slug), params: valid_params

          html = Nokogiri::HTML(response.body)
          expect(html.at_css("button[data-action='clipboard#copy']").text.squish).to eq "コピー"
        end
      end

      context "入力が正しくないとき" do
        let(:invalid_params) { { invitation: { username: "" } } }

        it "招待を作成しない" do
          expect {
            post studio_invitations_path(studio.slug), params: invalid_params
          }.not_to change(Invitation, :count)
        end

        it "422 を返して招待画面を再表示する" do
          post studio_invitations_path(studio.slug), params: invalid_params

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end
end
