class AddRoleToAdministrators < ActiveRecord::Migration[8.1]
  def change
    add_column :administrators, :role, :integer, null: false, default: 0
  end
end
