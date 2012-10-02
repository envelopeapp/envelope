object @mailbox
attributes :id, :name, :location, :uid_validity, :remote, :selectable, :last_synced

node :nested_mailboxes do |n|
  n.children.map{ |mailbox| partial('api/v1/accounts/nested_mailboxes', object: mailbox) }
end
