class Envelope.Models.Account extends Backbone.Model
  urlRoot: '/api/accounts'

  @find: (id) ->
    account = new Envelope.Models.Account({ id: id })
    account.fetch()
    account

  selectableMailboxes: ->
    _.select @get('mailboxes'), (mailbox) -> mailbox.selectable

  toJSON: ->
    json = { account: _.clone(@attributes) }
    json.account.incoming_server_attributes = @get('incoming_server_attributes')
    json.outgoing_server_attributes = @get('outgoing_server_attributes')
    json
