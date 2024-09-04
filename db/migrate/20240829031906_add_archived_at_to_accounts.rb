class AddArchivedAtToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_column :accounts, :archived_at, :datetime, null: true
  end
end
