class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
      t.integer :contact_id
      t.string :label
      t.string :phone_number

      t.timestamps
    end

    add_index :phones, :contact_id
  end
end
