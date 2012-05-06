class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.integer :user_id
      t.integer :incoming_server_id
      t.integer :outgoing_server_id
      t.string :name
      t.string :slug
      t.string :email_address
      t.string :reply_to_address
      t.string :imap_directory
      t.integer :inbox_mailbox_id
      t.integer :sent_mailbox_id
      t.integer :junk_mailbox_id
      t.integer :drafts_mailbox_id
      t.integer :trash_mailbox_id
      t.integer :starred_mailbox_id
      t.integer :important_mailbox_id
      t.datetime :last_synced

      t.timestamps
    end

    add_index :accounts, :user_id
    add_index :accounts, :incoming_server_id
    add_index :accounts, :outgoing_server_id
    add_index :accounts, :slug
    add_index :accounts, :email_address
    add_index :accounts, :inbox_mailbox_id
    add_index :accounts, :sent_mailbox_id
    add_index :accounts, :junk_mailbox_id
    add_index :accounts, :drafts_mailbox_id
    add_index :accounts, :trash_mailbox_id
    add_index :accounts, :starred_mailbox_id
    add_index :accounts, :important_mailbox_id
  end
end
