class Envelope.Mailbox extends Spine.Model
  @configure 'Mailbox', 'account_id', 'name', 'location', 'uid_validity', 'remote', 'selectable', 'last_synced'
  @belongsTo 'Account', 'Envelope.Account'
  @hasMany 'Messages', 'Envelope.Message'

  @extend Spine.Model.Ajax
