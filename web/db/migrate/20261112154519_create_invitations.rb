class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.references :studio, null: false, foreign_key: true
      t.references :inviter, null: false, foreign_key: { to_table: :administrators }
      t.string :username, null: false
      t.index :username
      t.string :token_digest, null: false
      t.index :token_digest, unique: true
      t.datetime :expires_at, null: false
      t.datetime :accepted_at
      t.datetime :canceled_at
      t.timestamps
    end
  end
end
