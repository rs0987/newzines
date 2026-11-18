class AddLockableToAdministrators < ActiveRecord::Migration[8.1]
  def change
    add_column :administrators, :failed_attempts, :integer, null: false, default: 0
    add_column :administrators, :locked_at, :datetime
  end
end
