class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.integer :contact_id
      t.string :label
      t.string :email_address

      t.timestamps
    end

    add_index :emails, :contact_id
    add_index :emails, :email_address
  end
end
