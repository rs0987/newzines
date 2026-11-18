class AddLockableToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :failed_attempts, :integer, null: false, default: 0
    add_column :accounts, :locked_at, :datetime
  end
end
