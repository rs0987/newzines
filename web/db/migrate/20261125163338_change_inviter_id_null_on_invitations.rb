class ChangeInviterIdNullOnInvitations < ActiveRecord::Migration[8.1]
  def change
    change_column_null :invitations, :inviter_id, true
  end
end
