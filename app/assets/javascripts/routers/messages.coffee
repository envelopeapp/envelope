class Envelope.Routers.Messages extends Backbone.Router
  routes:
    'accounts/:account_id/mailboxes/:mailbox_id/messages': 'index'
    'accounts/:account_id/mailboxes/:mailbox_id/messages/:id': 'show'

  index: (account_id, mailbox_id) ->
    account = new Envelope.Models.Account(id: account_id)
    account.fetch()

    account.mailboxes.where(mailbox_id: mailbox_id).messages.fetch()

  show: ->

