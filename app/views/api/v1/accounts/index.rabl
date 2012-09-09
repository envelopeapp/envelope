collection :@accounts

attributes :id,
           :name,
           :slug,
           :email_address,
           :reply_to_address,
           :imap_directory,
           :last_synced,
           :inbox_mailbox_id,
           :sent_mailbox_id,
           :junk_mailbox_id,
           :drafts_mailbox_id,
           :trash_mailbox_id,
           :starred_mailbox_id,
           :important_mailbox_id

child :user do
  attributes :name, :username
end

server_attributes = lambda do
  attributes :address, :port, :ssl

  child :server_authentication do
    attributes :username, :encrypted_password
  end
end

child :incoming_server do
  server_attributes.call
end

child :outgoing_server do
  server_attributes.call
end

child :mailboxes do
  attributes :id, :account_id, :name, :slug, :location, :selectable, :last_synced
end
