class PublicController < ApplicationController
  private

  def pundit_user
    # 公開サイトにはまだログインがないため、誰が見ても同じ扱いにする
    nil
  end
end
