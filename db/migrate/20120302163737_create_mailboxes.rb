class CreateMailboxes < ActiveRecord::Migration
  def change
    create_table :mailboxes do |t|
      t.integer :account_id
      t.string :ancestry
      t.integer :ancestry_depth, :default => 0
      t.string :name
      t.string :slug
      t.string :location
      t.integer :uid_validity
      t.boolean :remote, :default => false
      t.boolean :selectable, :default => false
      t.datetime :last_synced, :default => nil

      t.timestamps
    end

    add_index :mailboxes, :account_id
    add_index :mailboxes, :ancestry
    add_index :mailboxes, :ancestry_depth
    add_index :mailboxes, :slug
    add_index :mailboxes, :name
    add_index :mailboxes, :location
  end
end