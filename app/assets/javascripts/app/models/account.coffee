class Envelope.Account extends Spine.Model
  @configure 'Account', 'name', 'email_address', 'reply_to_address', 'imap_directory', 'last_synced'
  @hasMany 'mailboxes', 'Envelope.Mailbox'

  @extend Spine.Model.Ajax
  @url: '/api/accounts'
