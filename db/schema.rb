# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120411193903) do

  create_table "accounts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "incoming_server_id"
    t.integer  "outgoing_server_id"
    t.string   "name"
    t.string   "slug"
    t.string   "email_address"
    t.string   "reply_to_address"
    t.string   "imap_directory"
    t.integer  "inbox_mailbox_id"
    t.integer  "sent_mailbox_id"
    t.integer  "junk_mailbox_id"
    t.integer  "drafts_mailbox_id"
    t.integer  "trash_mailbox_id"
    t.integer  "starred_mailbox_id"
    t.integer  "important_mailbox_id"
    t.datetime "last_synced"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "accounts", ["drafts_mailbox_id"], :name => "index_accounts_on_drafts_mailbox_id"
  add_index "accounts", ["email_address"], :name => "index_accounts_on_email_address"
  add_index "accounts", ["important_mailbox_id"], :name => "index_accounts_on_important_mailbox_id"
  add_index "accounts", ["inbox_mailbox_id"], :name => "index_accounts_on_inbox_mailbox_id"
  add_index "accounts", ["incoming_server_id"], :name => "index_accounts_on_incoming_server_id"
  add_index "accounts", ["junk_mailbox_id"], :name => "index_accounts_on_junk_mailbox_id"
  add_index "accounts", ["outgoing_server_id"], :name => "index_accounts_on_outgoing_server_id"
  add_index "accounts", ["sent_mailbox_id"], :name => "index_accounts_on_sent_mailbox_id"
  add_index "accounts", ["slug"], :name => "index_accounts_on_slug"
  add_index "accounts", ["starred_mailbox_id"], :name => "index_accounts_on_starred_mailbox_id"
  add_index "accounts", ["trash_mailbox_id"], :name => "index_accounts_on_trash_mailbox_id"
  add_index "accounts", ["user_id"], :name => "index_accounts_on_user_id"

  create_table "addresses", :force => true do |t|
    t.integer  "contact_id"
    t.string   "label"
    t.string   "line_1"
    t.string   "line_2"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zip_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "addresses", ["contact_id"], :name => "index_addresses_on_contact_id"

  create_table "attachments", :force => true do |t|
    t.integer  "message_id"
    t.string   "file"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "attachments", ["message_id"], :name => "index_attachments_on_message_id"

  create_table "common_account_settings", :force => true do |t|
    t.string   "name"
    t.string   "incoming_server_address"
    t.integer  "incoming_server_port"
    t.boolean  "incoming_server_ssl"
    t.string   "outgoing_server_address"
    t.integer  "outgoing_server_port"
    t.boolean  "outgoing_server_ssl"
    t.string   "imap_directory"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "contacts", :force => true do |t|
    t.integer  "user_id"
    t.string   "prefix"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.string   "suffix"
    t.string   "nickname"
    t.string   "title"
    t.string   "department"
    t.date     "birthday"
    t.text     "notes"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "contacts", ["user_id"], :name => "index_contacts_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "emails", :force => true do |t|
    t.integer  "contact_id"
    t.string   "label"
    t.string   "email_address"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "emails", ["contact_id"], :name => "index_emails_on_contact_id"
  add_index "emails", ["email_address"], :name => "index_emails_on_email_address"

  create_table "labels", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "color"
    t.string   "icon"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "labels", ["name"], :name => "index_labels_on_name"
  add_index "labels", ["user_id"], :name => "index_labels_on_user_id"

  create_table "labels_messages", :id => false, :force => true do |t|
    t.integer "label_id"
    t.integer "message_id"
  end

  add_index "labels_messages", ["label_id"], :name => "index_labels_messages_on_label_id"
  add_index "labels_messages", ["message_id"], :name => "index_labels_messages_on_message_id"

  create_table "mailboxes", :force => true do |t|
    t.integer  "account_id"
    t.string   "ancestry"
    t.integer  "ancestry_depth", :default => 0
    t.string   "name"
    t.string   "slug"
    t.string   "location"
    t.integer  "uid_validity"
    t.boolean  "remote",         :default => false
    t.boolean  "selectable",     :default => false
    t.datetime "last_synced"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "mailboxes", ["account_id"], :name => "index_mailboxes_on_account_id"
  add_index "mailboxes", ["ancestry"], :name => "index_mailboxes_on_ancestry"
  add_index "mailboxes", ["ancestry_depth"], :name => "index_mailboxes_on_ancestry_depth"
  add_index "mailboxes", ["location"], :name => "index_mailboxes_on_location"
  add_index "mailboxes", ["name"], :name => "index_mailboxes_on_name"
  add_index "mailboxes", ["slug"], :name => "index_mailboxes_on_slug"

  create_table "messages", :force => true do |t|
    t.integer  "mailbox_id"
    t.string   "message_id"
    t.integer  "uid"
    t.string   "ancestry"
    t.integer  "ancestry_depth", :default => 0
    t.string   "subject"
    t.boolean  "read",           :default => false
    t.boolean  "downloaded",     :default => false
    t.boolean  "flagged",        :default => false
    t.text     "text_part"
    t.text     "html_part"
    t.string   "preview"
    t.text     "raw"
    t.datetime "date"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "messages", ["ancestry"], :name => "index_messages_on_ancestry"
  add_index "messages", ["ancestry_depth"], :name => "index_messages_on_ancestry_depth"
  add_index "messages", ["downloaded"], :name => "index_messages_on_downloaded"
  add_index "messages", ["mailbox_id"], :name => "index_messages_on_mailbox_id"
  add_index "messages", ["message_id"], :name => "index_messages_on_message_id"
  add_index "messages", ["read"], :name => "index_messages_on_read"
  add_index "messages", ["uid"], :name => "index_messages_on_uid"

  create_table "participants", :force => true do |t|
    t.integer  "message_id"
    t.integer  "contact_id"
    t.string   "participant_type"
    t.string   "name"
    t.string   "email_address"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "participants", ["contact_id"], :name => "index_participants_on_contact_id"
  add_index "participants", ["email_address"], :name => "index_participants_on_email_address"
  add_index "participants", ["message_id"], :name => "index_participants_on_message_id"
  add_index "participants", ["participant_type"], :name => "index_participants_on_participant_type"

  create_table "phones", :force => true do |t|
    t.integer  "contact_id"
    t.string   "label"
    t.string   "phone_number"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "phones", ["contact_id"], :name => "index_phones_on_contact_id"

  create_table "server_authentications", :force => true do |t|
    t.integer  "server_id"
    t.string   "username"
    t.string   "encrypted_password"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "server_authentications", ["server_id"], :name => "index_server_authentications_on_server_id"

  create_table "servers", :force => true do |t|
    t.string   "address"
    t.integer  "port"
    t.boolean  "ssl",        :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "email_address"
    t.string   "password_digest"
    t.string   "access_key"
    t.string   "secret_token"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email_address"], :name => "index_users_on_email_address", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
