class CreateCommonAccountSettings < ActiveRecord::Migration
  def change
    create_table :common_account_settings do |t|
      t.string :name
      t.string :incoming_server_address
      t.integer :incoming_server_port
      t.boolean :incoming_server_ssl
      t.string :outgoing_server_address
      t.integer :outgoing_server_port
      t.boolean :outgoing_server_ssl
      t.string :imap_directory

      t.timestamps
    end
  end
end
