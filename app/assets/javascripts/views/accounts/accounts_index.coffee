class Envelope.Views.AccountsIndex extends Backbone.View
  template: JST['accounts/index']

  initialize: ->
    @collection.on('reset', @render, @)

  render: ->
    $(@el).html(@template(accounts: @collection))
    @
