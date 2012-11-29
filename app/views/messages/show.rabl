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
           :toers,
           :fromers,
           :senders,
           :ccers,
           :bccers,
           :reply_toers

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
