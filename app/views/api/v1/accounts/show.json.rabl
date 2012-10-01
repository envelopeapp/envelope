object @account
attributes :name, :email_address, :reply_to_address, :imap_directory, :last_synced

node :id do |n|
  n._id.to_s
end

child :mailboxes do
  attributes :name, :location, :uid_validity, :remote, :selectable, :last_synced

  node :id do |n|
    n._id.to_s
  end
end

node :nested_mailboxes do |account|
  account.mailboxes.first.root.siblings.map { |mailbox| partial('api/v1/accounts/nested_mailboxes', :object => mailbox) }
end
