class Envelope.Message extends Spine.Model
  @configure 'Message', 'uid', 'message_id', 'subject', 'date', 'read', 'downloaded', 'flagged', 'text_part', 'html_part', 'preview', 'raw'
  @belongsTo 'Mailbox', 'Envelope.Mailbox'

  @extend Spine.Model.Ajax
