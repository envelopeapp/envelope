object @message
attributes :id,
           :uid,
           :account_id,
           :mailbox_id,
           :message_id,
           :subject,
           :timestamp,
           :flags,
           :read?,
           :flagged?,
           :answered?

[:toers, :fromers, :senders, :ccers, :bccers, :reply_toers].each do |type|
  node type do |message|
    partial 'participants/show', :object => message.participants.send(type)
  end
end

node :message_url do |message|
  account_mailbox_message_url(message.account_id, message.mailbox_id, message.id)
end

node :new_message_url do |message|
  new_account_mailbox_message_url(message.account_id, message.mailbox_id)
end

node :unread_message_url do |message|
  account_mailbox_message_unread_path(message.account_id, message.mailbox_id, message.id)
end

node :toggle_message_label_url do |message|
  account_mailbox_message_toggle_label_path(message.account_id, message.mailbox_id, message.id)
end

child :labels do
  extends 'labels/show'
end

child :attachments do
  extends 'attachments/show'
end

node :preview do |message|
  if message.text_part
    truncate(message.text_part.gsub("\n", ' ').strip, length: 300)
  else
    '<i>Preview unavailable...</i>'
  end
end

pipeline = HTML::Pipeline.new [
  HTML::Pipeline::MarkdownFilter,
  HTML::Pipeline::SanitizationFilter,
  HTML::Pipeline::SyntaxHighlightFilter,
  HTML::Pipeline::EmojiFilter,
  HTML::Pipeline::AutolinkFilter,
], { gfm: true, asset_root: asset_path(nil) }

node :text_part do |message|
  pipeline.call(message.text_part)[:output].to_s
end
