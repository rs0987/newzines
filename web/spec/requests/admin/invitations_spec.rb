require "rails_helper"

RSpec.describe "管理者サイトの招待管理", type: :request do
  let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }

  describe "GET /admin/studios/:studio_id/invitations" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get admin_studio_invitations_path(studio)

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in create(:administrator, role:) }

      context "閲覧者のとき" do
        let(:role) { :viewer }

        before { create(:invitation, studio:, username: "writer01") }

        it "スタジオの招待一覧を表示する" do
          get admin_studio_invitations_path(studio)

          expect(response.body).to include("writer01")
        end

        it "招待とキャンセルのボタンを押せない状態で表示する" do
          get admin_studio_invitations_path(studio)

          html = Nokogiri::HTML(response.body)
          expect(html.css("button[disabled]").map { |button| button.text.squish }).to eq [ "オーナーを招待", "キャンセル" ]
        end
      end

      context "編集者のとき" do
        let(:role) { :editor }

        before { create(:invitation, studio:, username: "writer01") }

        it "招待画面へのリンクと、押せるキャンセルボタンを表示する" do
          get admin_studio_invitations_path(studio)

          html = Nokogiri::HTML(response.body)
          invitation = Invitation.find_by(username: "writer01")
          expect(html.at_css("a[href='#{new_admin_studio_invitation_path(studio)}']").text).to eq "オーナーを招待"
          expect(html.at_css("form[action='#{cancel_admin_studio_invitation_path(studio, invitation)}'] button:not([disabled])").text).to eq "キャンセル"
        end
      end
    end
  end

  describe "GET /admin/studios/:studio_id/invitations/new" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get new_admin_studio_invitation_path(studio)

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in create(:administrator, role:) }

      context "閲覧者のとき" do
        let(:role) { :viewer }

        it "ダッシュボードにリダイレクトする" do
          get new_admin_studio_invitation_path(studio)

          expect(response).to redirect_to(admin_root_path)
        end
      end

      context "編集者のとき" do
        let(:role) { :editor }

        it "招待画面を表示する" do
          get new_admin_studio_invitation_path(studio)

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe "POST /admin/studios/:studio_id/invitations" do
    let(:valid_params) { { invitation: { username: "writer01" } } }

    context "ログインしていないとき" do
      it "招待を作成しない" do
        expect {
          post admin_studio_invitations_path(studio), params: valid_params
        }.not_to change(Invitation, :count)
      end

      it "ログイン画面にリダイレクトする" do
        post admin_studio_invitations_path(studio), params: valid_params

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in administrator }

      context "閲覧者のとき" do
        let(:administrator) { create(:administrator, role: :viewer) }

        it "招待を作成しない" do
          expect {
            post admin_studio_invitations_path(studio), params: valid_params
          }.not_to change(Invitation, :count)
        end

        it "303 でダッシュボードにリダイレクトする" do
          post admin_studio_invitations_path(studio), params: valid_params

          expect([ response.status, response.location ]).to eq [ 303, admin_root_url ]
        end
      end

      context "編集者のとき" do
        let(:administrator) { create(:administrator, role: :editor) }

        context "入力が正しいとき" do
          it "ログイン中の管理者を招待者として、スタジオのオーナーへの招待を作成する" do
            post admin_studio_invitations_path(studio), params: valid_params

            invitation = Invitation.find_by(username: "writer01")
            expect([ invitation.studio, invitation.inviter, invitation.role ]).to eq [ studio, administrator, "owner" ]
          end

          it "招待 URL をコピーできる画面を表示する" do
            post admin_studio_invitations_path(studio), params: valid_params

            html = Nokogiri::HTML(response.body)
            expect(html.at_css("button[data-action='clipboard#copy']").text.squish).to eq "コピー"
          end
        end

        context "入力が正しくないとき" do
          let(:invalid_params) { { invitation: { username: "" } } }

          it "招待を作成しない" do
            expect {
              post admin_studio_invitations_path(studio), params: invalid_params
            }.not_to change(Invitation, :count)
          end

          it "422 を返して招待画面を再表示する" do
            post admin_studio_invitations_path(studio), params: invalid_params

            expect(response).to have_http_status(:unprocessable_content)
          end
        end
      end
    end
  end

  describe "PATCH /admin/studios/:studio_id/invitations/:id/cancel" do
    let(:invitation) { create(:invitation, studio:, username: "writer01") }

    context "ログインしていないとき" do
      it "招待をキャンセルしない" do
        patch cancel_admin_studio_invitation_path(studio, invitation)

        expect(invitation.reload.canceled_at).to be_nil
      end

      it "ログイン画面にリダイレクトする" do
        patch cancel_admin_studio_invitation_path(studio, invitation)

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in create(:administrator, role:) }

      context "閲覧者のとき" do
        let(:role) { :viewer }

        it "招待をキャンセルしない" do
          patch cancel_admin_studio_invitation_path(studio, invitation)

          expect(invitation.reload.canceled_at).to be_nil
        end

        it "303 でダッシュボードにリダイレクトする" do
          patch cancel_admin_studio_invitation_path(studio, invitation)

          expect([ response.status, response.location ]).to eq [ 303, admin_root_url ]
        end
      end

      context "編集者のとき" do
        let(:role) { :editor }

        context "受諾待ちの招待のとき" do
          it "招待をキャンセルする" do
            patch cancel_admin_studio_invitation_path(studio, invitation)

            expect(invitation.reload.canceled_at).to be_present
          end

          it "303 で招待一覧にリダイレクトする" do
            patch cancel_admin_studio_invitation_path(studio, invitation)

            expect([ response.status, response.location ]).to eq [ 303, admin_studio_invitations_url(studio) ]
          end
        end

        context "受諾済みの招待のとき" do
          let(:invitation) { create(:invitation, studio:, username: "writer01", accepted_at: Time.current) }

          it "招待をキャンセルしない" do
            patch cancel_admin_studio_invitation_path(studio, invitation)

            expect(invitation.reload.canceled_at).to be_nil
          end

          it "303 で招待一覧にリダイレクトする" do
            patch cancel_admin_studio_invitation_path(studio, invitation)

            expect([ response.status, response.location ]).to eq [ 303, admin_studio_invitations_url(studio) ]
          end
        end
      end
    end
  end
end
