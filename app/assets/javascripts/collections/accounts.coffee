class Envelope.Collections.Accounts extends Backbone.Collection
  url: '/api/accounts'

  model: Envelope.Models.Account

  comparator: (account) ->
    account.get('name').toUpperCase()
