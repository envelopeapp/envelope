class Envelope.Views.AccountsShow extends Backbone.View
  template: JST['accounts/show']

  initialize: ->
    @model.on('change', @render, @)

  render: ->
    $(@el).html(@template(account: @model))
    @
