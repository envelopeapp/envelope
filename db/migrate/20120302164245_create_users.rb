class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :username
      t.string :email_address
      t.string :password_digest

      # Rememberable
      t.string :auth_token

      # Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      # Confirmable
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at

      t.timestamps
    end

    add_index :users, :username, :unique => true
    add_index :users, :email_address, :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token, :unique => true
  end
end
