class Studios::BaseController < ApplicationController
  layout "studio_with_menu"

  before_action :authenticate_account!
  before_action :set_studio_membership
  after_action :verify_authorized

  private

  def pundit_user
    current_account
  end

  def set_studio_membership
    @studio_membership = policy_scope([ :studios, StudioMembership ])
                           .joins(:studio)
                           .find_by!(studios: { slug: params.expect(:studio_slug) })
    @studio = @studio_membership.studio
  end
end
