object @account
attributes :id, :name, :email_address, :reply_to_address, :imap_directory, :last_synced

child :mailboxes do
  attributes :id, :name, :location, :uid_validity, :remote, :selectable, :last_synced
end

node :nested_mailboxes do |account|
  account.mailboxes.first.root.siblings.map { |mailbox| partial('api/v1/accounts/nested_mailboxes', :object => mailbox) }
end

child incoming_server: :incoming_server do
  attributes :id, :address, :port, :ssl

  child :authentication do
    attributes :id, :username
  end
end

child outgoing_server: :outgoing_server do
  attributes :id, :address, :port, :ssl

  child :authentication do
    attributes :id, :username
  end
end
