class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer :message_id
      t.string :file

      t.timestamps
    end

    add_index :attachments, :message_id
  end
end
