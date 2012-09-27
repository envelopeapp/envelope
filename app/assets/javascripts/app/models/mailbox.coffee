class Envelope.Mailbox extends Spine.Model
  @configure 'Mailbox', 'account_id', 'name', 'location', 'uid_validity', 'remote', 'selectable', 'last_synced'
  @belongsTo 'Account', 'Envelope.Account'

  @extend Spine.Model.Ajax
