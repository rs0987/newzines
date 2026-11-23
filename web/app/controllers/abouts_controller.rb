class AboutsController < PublicController
  # 「このサイトについて」は誰でも見てよいためスキップ
  skip_after_action :verify_pundit_authorization

  def show
  end
end
