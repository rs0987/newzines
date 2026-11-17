# frozen_string_literal: true

class Admin::SessionsController < Devise::SessionsController
  layout "admin"

  private

    def after_sign_in_path_for(resource)
      stored_location_for(resource) || admin_root_path
    end

    def after_sign_out_path_for(_resource_or_scope)
      new_administrator_session_path
    end
end
