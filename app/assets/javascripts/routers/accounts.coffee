class Envelope.Routers.Accounts extends Backbone.Router
  routes:
    'accounts': 'index'
    'accounts/new': 'new'
    'accounts/:id': 'show'

  initialize: ->
    # nothing yet

  index: ->
    @collection = new Envelope.Collections.Accounts()
    @collection.fetch()

    view = new Envelope.Views.AccountsIndex(collection: @collection)
    $('#container').html(view.render().el)

  show: (id) ->
    @model = Envelope.Models.Account.find(id)

    view = new Envelope.Views.AccountsShow(model: @model)
    $('#container').html(view.render().el)

  new: (id) ->
    @model = new Envelope.Models.Account()
    @common_account_settings = new Envelope.Collections.CommonAccountSettings()
    @common_account_settings.fetch()

    view = new Envelope.Views.AccountsNew(model: @model, common_account_settings: @common_account_settings)
    $('#container').html(view.render().el)
