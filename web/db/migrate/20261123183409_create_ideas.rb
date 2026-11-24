class CreateIdeas < ActiveRecord::Migration[8.1]
  def change
    create_table :ideas do |t|
      # 下の [studio_id, archived_at] のインデックスが代わりになるため、studio_id だけのインデックスは張らない。
      t.references :studio, null: false, foreign_key: true, index: false
      t.references :writer, null: false, foreign_key: true
      t.string :title
      t.text :body
      t.datetime :archived_at
      t.index %i[studio_id archived_at]

      t.timestamps
    end
  end
end
