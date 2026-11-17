class PageDecorator < SimpleDelegator
  # 入力エラーで画面を再表示したときに、パンくずや見出しがまだ保存していない入力値に変わらないよう、保存済みのタイトルを使う
  def display_title
    title_in_database.presence || "（タイトル未定）"
  end
end
