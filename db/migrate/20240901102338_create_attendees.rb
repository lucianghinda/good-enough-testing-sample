class CreateAttendees < ActiveRecord::Migration[7.2]
  def change
    create_table :attendees do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :status, null: false, default: "registered"
      t.timestamps
    end
  end
end
