class CreateLabelsMessages < ActiveRecord::Migration
  def change
    create_table :labels_messages, :force => true, :id => false do |t|
      t.integer :label_id
      t.integer :message_id
    end

    add_index :labels_messages, :label_id
    add_index :labels_messages, :message_id
  end
end