class Envelope.Models.Mailbox extends Backbone.Model

  initialize: ->
    @messages = new Envelope.Collections.Messages()
    @messages.url = "/api/accounts/#{@get('account_id')}/mailboxes/#{@get('id')}/messages"
    @messages.on 'reset', -> console.log 'Reset messages'
