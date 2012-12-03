object @mailbox
attributes :id,
           :name,
           :location,
           :flag,
           :uid_validity,
           :remote,
           :last_synced,
           :last_seen_uid

node :unread_messages_count do |mailbox|
  mailbox.messages.unread.size
end
