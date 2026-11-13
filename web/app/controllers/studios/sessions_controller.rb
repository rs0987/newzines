# frozen_string_literal: true

class Studios::SessionsController < Devise::SessionsController
  layout "studio"

  def create
    super do |account|
      unless first_studio
        # ログインしたままログイン画面に戻すと、ログイン済みとしてまたここへ戻されてしまうため、ログアウトさせる
        sign_out(account)
        # Devise がブロックの前に入れた「ログインしました」を消す
        flash.delete(:notice)
        redirect_to new_account_session_path, alert: "所属しているスタジオがありません", status: :see_other
        return
      end
    end
  end

  private

  def pundit_user
    current_account
  end

  def after_sign_in_path_for(account)
    stored_location_for(account) || studio_root_path(first_studio.slug)
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_account_session_path
  end

  def first_studio
    policy_scope([ :studios, StudioMembership ]).order(:id).first&.studio
  end
end
