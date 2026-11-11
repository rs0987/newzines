class Admin::DashboardsController < Admin::BaseController
  def show
    authorize [ :admin, :dashboard ]
  end
end
