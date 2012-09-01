class Envelope.Routers.Accounts extends Backbone.Router
  routes:
    'foo/bar': 'index'

  initialize: ->
    @collection = new Envelope.Collections.Accounts()
    @collection.fetch()

  index: ->
    view = new Envelope.Views.AccountsIndex(collection: @collection)
    $('#container').html(view.render().el)
