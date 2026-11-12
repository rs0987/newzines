class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :username, null: false
      t.index :username, unique: true
      t.string :encrypted_password, null: false, default: ""
      t.timestamps
    end
  end
end
