object @attachment
attributes :id, :filename, :path

node :attachment_url do |attachment|
  message = attachment.message
  account_mailbox_message_attachment_path(message.account_id, message.maibox_id, message.id, attachment.id)
end
