class PublicController < ApplicationController
  rescue_from Pundit::NotAuthorizedError, with: :not_found

  private

  def pundit_user
    # 公開サイトにはまだログインがないため、誰が見ても同じ扱いにする
    nil
  end

  def not_found
    # 閲覧できないものがあることを知らせないよう、権限がないときも存在しないときと同じにする
    raise ActiveRecord::RecordNotFound
  end
end
