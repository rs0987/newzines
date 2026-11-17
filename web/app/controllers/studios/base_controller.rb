class Studios::BaseController < ApplicationController
  layout "studio_with_menu"

  before_action :authenticate_account!
  before_action :set_studio_membership
  after_action :verify_pundit_authorization

  rescue_from Pundit::NotAuthorizedError, with: :account_not_authorized

  private

    def pundit_user
      current_account
    end

    def set_studio_membership
      # コントローラーの policy_scope を使うと、すべてのアクションで呼んだ扱いになり、verify_policy_scoped で呼び忘れに気づけなくなるため使わない
      @studio_membership = Pundit.policy_scope!(current_account, [ :studios, StudioMembership ])
                             .joins(:studio)
                             .find_by!(studios: { slug: params.expect(:studio_slug) })
      @studio = @studio_membership.studio
    end

    def verify_pundit_authorization
      if action_name == "index"
        verify_policy_scoped
      else
        verify_authorized
      end
    end

    def account_not_authorized
      redirect_back_or_to studio_root_path(@studio.slug), alert: "この操作を行う権限がありません", status: :see_other
    end
end
