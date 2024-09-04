class CreateAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.date :expires_at, null: true
      t.timestamps
    end
  end
end
