class ChangeRoleNullAndDefaultOnInvitations < ActiveRecord::Migration[8.1]
  def change
    change_column_null :invitations, :role, false
    change_column_default :invitations, :role, from: nil, to: 0
  end
end
