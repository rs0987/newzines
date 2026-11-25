class ContractInviterOnInvitations < ActiveRecord::Migration[8.1]
  def change
    change_table :invitations do |t|
      t.remove_references :inviter, foreign_key: { to_table: :administrators }
      t.check_constraint <<~SQL.squish, name: "invitations_inviter_presence"
        (inviter_administrator_id IS NOT NULL AND inviter_writer_id IS NULL)
        OR (inviter_administrator_id IS NULL AND inviter_writer_id IS NOT NULL)
      SQL
    end
  end
end
