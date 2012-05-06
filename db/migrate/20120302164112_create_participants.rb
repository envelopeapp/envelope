class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.integer :message_id
      t.integer :contact_id
      t.string :participant_type
      t.string :name
      t.string :email_address

      t.timestamps
    end

    add_index :participants, :message_id
    add_index :participants, :contact_id
    add_index :participants, :participant_type
    add_index :participants, :email_address
  end
end
