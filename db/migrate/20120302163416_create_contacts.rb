class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :user_id
      t.string :prefix
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.string :suffix
      t.string :nickname
      t.string :title
      t.string :department
      t.date :birthday
      t.text :notes

      t.timestamps
    end

    add_index :contacts, :user_id
  end
end
