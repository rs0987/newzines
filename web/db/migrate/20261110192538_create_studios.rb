class CreateStudios < ActiveRecord::Migration[8.1]
  def change
    create_table :studios do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :studios, :slug, unique: true
  end
end
