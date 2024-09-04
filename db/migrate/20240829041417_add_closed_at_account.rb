class AddClosedAtAccount < ActiveRecord::Migration[7.2]
  def change
    add_column :accounts, :closed_at, :datetime, null: true
  end
end
