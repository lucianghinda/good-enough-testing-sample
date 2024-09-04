class AddPremiumToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :premium, :boolean, default: false
  end
end
