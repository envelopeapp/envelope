class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |t|
      t.integer :user_id
      t.string :name
      t.string :color
      t.string :icon

      t.timestamps
    end

    add_index :labels, :name
    add_index :labels, :user_id
  end
end
