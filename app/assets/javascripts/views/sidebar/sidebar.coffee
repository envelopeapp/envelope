class Envelope.Views.Sidebar extends Backbone.View
  template: JST['sidebar/sidebar']

  events:
    'click foo': -> console.log 'hi'

  initialize: ->
    @collection.on('reset', @render, @)

  render: ->
    $(@el).html(@template(accounts: @collection))
    @
