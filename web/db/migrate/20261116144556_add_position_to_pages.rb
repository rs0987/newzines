class AddPositionToPages < ActiveRecord::Migration[8.1]
  def change
    add_column :pages, :position, :integer, null: false, default: 0
    add_index :pages, %i[zine_id position]
  end
end
