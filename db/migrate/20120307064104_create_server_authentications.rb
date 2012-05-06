class CreateServerAuthentications < ActiveRecord::Migration
  def change
    create_table :server_authentications do |t|
      t.integer :server_id
      t.string :username
      t.string :encrypted_password

      t.timestamps
    end

    add_index :server_authentications, :server_id
  end
end
