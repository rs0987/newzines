class AddNoteToPages < ActiveRecord::Migration[8.1]
  def change
    add_column :pages, :note, :text
  end
end
