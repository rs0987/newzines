class HomesController < PublicController
  RECENT_ZINES_LIMIT = 5

  # ホームは誰でも見てよいためスキップ
  skip_after_action :verify_pundit_authorization
  after_action :verify_policy_scoped

  def show
    @zines = policy_scope(Zine).includes(:studio).order(published_at: :desc, id: :desc).limit(RECENT_ZINES_LIMIT)
  end
end
