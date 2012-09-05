class Envelope.Views.AccountsIndex extends Backbone.View
  template: JST['accounts/index']

  events:
    'click a[data-account-id]': 'show'

  initialize: ->
    @collection.on('reset', @render, @)

  show: (event) ->
    event.preventDefault()
    id = $(event.target).attr('data-account-id')
    Backbone.history.navigate("accounts/#{id}", trigger: true)

  render: ->
    $(@el).html(@template(accounts: @collection))
    @
