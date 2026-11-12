require "rails_helper"

RSpec.describe "管理者サイトのスタジオ管理", type: :request do
  describe "GET /admin/studios" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get admin_studios_path

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in create(:administrator, role:) }

      context "閲覧者のとき" do
        let(:role) { :viewer }
        let!(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }

        it "スタジオ一覧を表示する" do
          get admin_studios_path

          expect(response.body).to include("映画好きの集まり")
        end

        it "作成ボタンを押せない状態で表示する" do
          get admin_studios_path

          html = Nokogiri::HTML(response.body)
          expect(html.at_css("button[disabled]").text).to eq "スタジオを作成"
        end
      end

      context "編集者のとき" do
        let(:role) { :editor }

        it "作成画面へのリンクを表示する" do
          get admin_studios_path

          html = Nokogiri::HTML(response.body)
          expect(html.at_css("a[href='#{new_admin_studio_path}']").text).to eq "スタジオを作成"
        end
      end
    end
  end

  describe "GET /admin/studios/:id" do
    let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }

    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get admin_studio_path(studio)

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in create(:administrator, role:) }

      context "閲覧者のとき" do
        let(:role) { :viewer }

        it "スタジオの詳細を表示する" do
          get admin_studio_path(studio)

          expect(response.body).to include("cinema01")
        end

        it "編集と削除のボタンを押せない状態で表示する" do
          get admin_studio_path(studio)

          html = Nokogiri::HTML(response.body)
          expect(html.css("button[disabled]").map { |button| button.text.squish }).to eq [ "編集", "削除" ]
        end
      end

      context "編集者のとき" do
        let(:role) { :editor }

        it "スタジオの詳細を表示する" do
          get admin_studio_path(studio)

          expect(response.body).to include("cinema01")
        end

        it "編集画面へのリンクと、押せる削除ボタンを表示する" do
          get admin_studio_path(studio)

          html = Nokogiri::HTML(response.body)
          expect(html.at_css("a[href='#{edit_admin_studio_path(studio)}']").text).to eq "編集"
          expect(html.at_css("form[action='#{admin_studio_path(studio)}'] button:not([disabled])").text).to eq "削除"
        end
      end
    end
  end

  describe "GET /admin/studios/new" do
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get new_admin_studio_path

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in create(:administrator, role:) }

      context "閲覧者のとき" do
        let(:role) { :viewer }

        it "ダッシュボードにリダイレクトする" do
          get new_admin_studio_path

          expect(response).to redirect_to(admin_root_path)
        end
      end

      context "編集者のとき" do
        let(:role) { :editor }

        it "作成画面を表示する" do
          get new_admin_studio_path

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe "POST /admin/studios" do
    let(:valid_params) { { studio: { name: "映画好きの集まり", slug: "cinema01" } } }

    context "ログインしていないとき" do
      it "スタジオを作成しない" do
        expect {
          post admin_studios_path, params: valid_params
        }.not_to change(Studio, :count)
      end

      it "ログイン画面にリダイレクトする" do
        post admin_studios_path, params: valid_params

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in create(:administrator, role:) }

      context "閲覧者のとき" do
        let(:role) { :viewer }

        it "スタジオを作成しない" do
          expect {
            post admin_studios_path, params: valid_params
          }.not_to change(Studio, :count)
        end

        it "303 でダッシュボードにリダイレクトする" do
          post admin_studios_path, params: valid_params

          expect([ response.status, response.location ]).to eq [ 303, admin_root_url ]
        end
      end

      context "編集者のとき" do
        let(:role) { :editor }

        context "入力が正しいとき" do
          it "スタジオを作成する" do
            post admin_studios_path, params: valid_params

            studio = Studio.find_by(slug: "cinema01")
            expect(studio.name).to eq "映画好きの集まり"
          end

          it "作成したスタジオの詳細画面にリダイレクトする" do
            post admin_studios_path, params: valid_params

            studio = Studio.find_by(slug: "cinema01")
            expect(response).to redirect_to(admin_studio_path(studio))
          end
        end

        context "入力が正しくないとき" do
          let(:invalid_params) { { studio: { name: "", slug: "cinema01" } } }

          it "スタジオを作成しない" do
            expect {
              post admin_studios_path, params: invalid_params
            }.not_to change(Studio, :count)
          end

          it "422 を返して作成画面を再表示する" do
            post admin_studios_path, params: invalid_params

            expect(response).to have_http_status(:unprocessable_content)
          end
        end
      end
    end
  end

  describe "GET /admin/studios/:id/edit" do
    let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }

    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトする" do
        get edit_admin_studio_path(studio)

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in create(:administrator, role:) }

      context "閲覧者のとき" do
        let(:role) { :viewer }

        it "ダッシュボードにリダイレクトする" do
          get edit_admin_studio_path(studio)

          expect(response).to redirect_to(admin_root_path)
        end
      end

      context "編集者のとき" do
        let(:role) { :editor }

        it "編集画面を表示する" do
          get edit_admin_studio_path(studio)

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe "PATCH /admin/studios/:id" do
    let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }
    let(:valid_params) { { studio: { name: "シネマクラブ" } } }

    context "ログインしていないとき" do
      it "スタジオ名を更新しない" do
        patch admin_studio_path(studio), params: valid_params

        expect(studio.reload.name).to eq "映画好きの集まり"
      end

      it "ログイン画面にリダイレクトする" do
        patch admin_studio_path(studio), params: valid_params

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in create(:administrator, role:) }

      context "閲覧者のとき" do
        let(:role) { :viewer }

        it "スタジオ名を更新しない" do
          patch admin_studio_path(studio), params: valid_params

          expect(studio.reload.name).to eq "映画好きの集まり"
        end

        it "303 でダッシュボードにリダイレクトする" do
          patch admin_studio_path(studio), params: valid_params

          expect([ response.status, response.location ]).to eq [ 303, admin_root_url ]
        end
      end

      context "編集者のとき" do
        let(:role) { :editor }

        context "入力が正しいとき" do
          it "スタジオ名を更新する" do
            patch admin_studio_path(studio), params: valid_params

            expect(studio.reload.name).to eq "シネマクラブ"
          end

          it "スタジオの詳細画面にリダイレクトする" do
            patch admin_studio_path(studio), params: valid_params

            expect(response).to redirect_to(admin_studio_path(studio))
          end
        end

        context "slug を送ったとき" do
          it "slug を変更しない" do
            patch admin_studio_path(studio), params: { studio: { name: "シネマクラブ", slug: "movie01" } }

            expect(studio.reload.slug).to eq "cinema01"
          end
        end

        context "入力が正しくないとき" do
          let(:invalid_params) { { studio: { name: "" } } }

          it "スタジオ名を更新しない" do
            patch admin_studio_path(studio), params: invalid_params

            expect(studio.reload.name).to eq "映画好きの集まり"
          end

          it "422 を返して編集画面を再表示する" do
            patch admin_studio_path(studio), params: invalid_params

            expect(response).to have_http_status(:unprocessable_content)
          end
        end
      end
    end
  end

  describe "DELETE /admin/studios/:id" do
    let(:studio) { create(:studio, name: "映画好きの集まり", slug: "cinema01") }

    context "ログインしていないとき" do
      it "スタジオを削除しない" do
        delete admin_studio_path(studio)

        expect(Studio.exists?(studio.id)).to be true
      end

      it "ログイン画面にリダイレクトする" do
        delete admin_studio_path(studio)

        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    context "ログインしているとき" do
      before { sign_in create(:administrator, role:) }

      context "閲覧者のとき" do
        let(:role) { :viewer }

        it "スタジオを削除しない" do
          delete admin_studio_path(studio)

          expect(Studio.exists?(studio.id)).to be true
        end

        it "303 でダッシュボードにリダイレクトする" do
          delete admin_studio_path(studio)

          expect([ response.status, response.location ]).to eq [ 303, admin_root_url ]
        end
      end

      context "編集者のとき" do
        let(:role) { :editor }

        it "スタジオを削除する" do
          delete admin_studio_path(studio)

          expect(Studio.exists?(studio.id)).to be false
        end

        it "スタジオ一覧にリダイレクトする" do
          delete admin_studio_path(studio)

          expect(response).to redirect_to(admin_studios_path)
        end
      end
    end
  end
end
