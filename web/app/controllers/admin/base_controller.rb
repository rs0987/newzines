class Admin::BaseController < ApplicationController
  layout "admin_with_menu"

  before_action :authenticate_administrator!
  after_action :verify_pundit_authorization

  rescue_from Pundit::NotAuthorizedError, with: :administrator_not_authorized

  private

  def pundit_user
    current_administrator
  end

  def verify_pundit_authorization
    if action_name == "index"
      verify_policy_scoped
    else
      verify_authorized
    end
  end

  def administrator_not_authorized
    redirect_back_or_to admin_root_path, alert: "この操作を行う権限がありません", status: :see_other
  end
end
