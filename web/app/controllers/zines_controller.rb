class ZinesController < PublicController
  ZINES_PER_PAGE = 10

  def index
    @zines = policy_scope(Zine).includes(:studio).order(published_at: :desc, id: :desc).page(params[:page]).per(ZINES_PER_PAGE)
  end

  def show
    @zine = Zine.find(params.expect(:id))
    authorize @zine

    @pages = policy_scope(@zine.pages).includes(writer: :account)
  end
end
