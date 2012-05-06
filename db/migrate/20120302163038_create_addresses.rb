class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.integer :contact_id
      t.string :label
      t.string :line_1
      t.string :line_2
      t.string :city
      t.string :state
      t.string :country
      t.string :zip_code

      t.timestamps
    end

    add_index :addresses, :contact_id
  end
end
