class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :mailbox_id
      t.string :message_id
      t.integer :uid
      t.string :ancestry
      t.integer :ancestry_depth, :default => 0
      t.string :subject
      t.boolean :read, :default => false
      t.boolean :downloaded, :default => false
      t.boolean :flagged, :default => false
      t.text :text_part
      t.text :html_part
      t.string :preview
      t.text :raw
      t.datetime :date

      t.timestamps
    end

    add_index :messages, :mailbox_id
    add_index :messages, :message_id
    add_index :messages, :uid
    add_index :messages, :ancestry
    add_index :messages, :ancestry_depth
    add_index :messages, :read
    add_index :messages, :downloaded
  end
end
