class HomesController < ApplicationController
  after_action :verify_policy_scoped

  def show
    @zines = policy_scope(Zine).includes(:studio).order(published_at: :desc, id: :desc)
  end

  private

  def pundit_user
    # 公開サイトにはまだログインがないため、誰が見ても同じ扱いにする
    nil
  end
end
