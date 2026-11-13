class Studios::DashboardsController < Studios::BaseController
  def show
    authorize [ :studios, :dashboard ]
  end
end
