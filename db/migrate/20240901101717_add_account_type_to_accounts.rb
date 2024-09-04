class AddAccountTypeToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_column :accounts, :account_type, :string, null: false, default: "free"
  end
end
