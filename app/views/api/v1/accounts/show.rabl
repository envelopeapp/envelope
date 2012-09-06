object :@account

attributes :name,
           :slug,
           :email_address,
           :reply_to_address,
           :imap_directory,
           :last_synced

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
