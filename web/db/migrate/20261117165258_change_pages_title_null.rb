class ChangePagesTitleNull < ActiveRecord::Migration[8.1]
  def change
    change_column_null :pages, :title, true
  end
end
