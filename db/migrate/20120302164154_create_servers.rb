class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :address
      t.integer :port
      t.boolean :ssl, :default => true

      t.timestamps
    end
  end
end
