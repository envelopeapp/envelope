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

child :outgoing_server

# create_table "accounts", :force => true do |t|
#   t.integer  "user_id"
#   t.integer  "incoming_server_id"
#   t.integer  "outgoing_server_id"
#   t.string   "name"
#   t.string   "slug"
#   t.string   "email_address"
#   t.string   "reply_to_address"
#   t.string   "imap_directory"
#   t.integer  "inbox_mailbox_id"
#   t.integer  "sent_mailbox_id"
#   t.integer  "junk_mailbox_id"
#   t.integer  "drafts_mailbox_id"
#   t.integer  "trash_mailbox_id"
#   t.integer  "starred_mailbox_id"
#   t.integer  "important_mailbox_id"
#   t.datetime "last_synced"
#   t.datetime "created_at",           :null => false
#   t.datetime "updated_at",           :null => false
# end
