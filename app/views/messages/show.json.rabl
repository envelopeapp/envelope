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
           :answered?,
           :text_part,
           :sanitized_html

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
  attributes :id, :filename, :path

  node :attachment_url do |attachment|
    message = attachment.message
    account_mailbox_message_attachment_path(message.account_id, message.mailbox_id, message.id, attachment.id, attachment.filename)
  end
end

node :preview do |message|
  if message.text_part
    truncate(message.text_part.gsub("\n", ' ').strip, length: 300)
  else
    '<i>This message has no content</i>'
  end
end

TextPipeline = HTML::Pipeline.new [
  HTML::Pipeline::MarkdownFilter,
  HTML::Pipeline::SanitizationFilter,
  HTML::Pipeline::AutolinkFilter,
  HTML::Pipeline::MentionFilter,
  HTML::Pipeline::EmojiFilter,
  HTML::Pipeline::SyntaxHighlightFilter
], gfm: true, asset_root: asset_path(''), base_url: 'http://twitter.com/'

HTMLPipeline = HTML::Pipeline.new [
  HTML::Pipeline::SanitizationFilter
]
node :content do |message|
  if message.text_part
    TextPipeline.call(message.text_part)[:output]
  else
    if message.html_part
      HTMLPipeline.call(message.html_part)[:output]
    else
      '<i>This message has no content...</i>'
    end
  end
end
