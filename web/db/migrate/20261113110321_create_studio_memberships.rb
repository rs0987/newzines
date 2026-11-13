class CreateStudioMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :studio_memberships do |t|
      # [studio_id, writer_id] の複合インデックスが studio_id での検索も兼ねるので、単体のインデックスは作らない
      t.references :studio, null: false, foreign_key: true, index: false
      t.references :writer, null: false, foreign_key: true
      t.index [ :studio_id, :writer_id ], unique: true
      t.integer :role, null: false, default: 0
      t.timestamps
    end
  end
end
