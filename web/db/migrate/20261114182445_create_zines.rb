class CreateZines < ActiveRecord::Migration[8.1]
  def change
    create_table :zines do |t|
      t.references :studio, null: false, foreign_key: true
      t.references :editor, null: false, foreign_key: { to_table: :writers }
      t.string :title, null: false
      t.text :description
      t.datetime :published_at
      t.timestamps
    end
  end
end
