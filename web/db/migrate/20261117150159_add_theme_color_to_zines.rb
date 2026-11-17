class AddThemeColorToZines < ActiveRecord::Migration[8.1]
  def change
    add_column :zines, :theme_color, :string, null: false, default: "retro"
  end
end
