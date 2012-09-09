class Envelope.Models.Account extends Backbone.Model
  urlRoot: '/api/accounts'

  @find: (id) ->
    account = new Envelope.Models.Account({ id: id })
    account.fetch()
    account

  initialize: ->
    @mailboxes = new Envelope.Collections.Mailboxes()
    @mailboxes.url = "/api/accounts/#{@get('id')}/mailboxes"
    @mailboxes.bind 'reset', -> console.log @mailboxes

  selectableMailboxes: ->
    _.sortBy _.select(@get('mailboxes'), (mailbox) -> mailbox.selectable), (mailbox) -> mailbox.name

  toJSON: ->
    json = { account: _.clone(@attributes) }
    json.account.incoming_server_attributes = @get('incoming_server_attributes')
    json.outgoing_server_attributes = @get('outgoing_server_attributes')
    json
