object :@account

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

child :incoming_server do
  extends 'api/v1/servers/show'
end

child :outgoing_server do
  extends 'api/v1/servers/show'
end

child :mailboxes do
  extends 'api/v1/mailboxes/index'
end
