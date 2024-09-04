# frozen_string_literal: true

class AddWebsiteToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_column :accounts, :website, :string, null: true
  end
end
