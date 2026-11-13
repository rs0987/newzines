# frozen_string_literal: true

class Studios::SessionsController < Devise::SessionsController
  layout "studio"

  private

  def after_sign_out_path_for(_resource_or_scope)
    new_account_session_path
  end
end
