object @attachment
attributes :id, :filename, :path

node :attachment_url do |attachment|
  message = attachment.message
  Rails.application.routes.url_helpers.account_mailbox_message_attachment_path(message.account_id, message.mailbox_id, message.id, attachment.id)
end
