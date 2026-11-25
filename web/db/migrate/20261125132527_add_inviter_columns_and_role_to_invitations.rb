class AddInviterColumnsAndRoleToInvitations < ActiveRecord::Migration[8.1]
  def change
    change_table :invitations do |t|
      t.references :inviter_administrator, foreign_key: { to_table: :administrators }
      t.references :inviter_writer, foreign_key: { to_table: :writers }
      t.integer :role
    end
  end
end
