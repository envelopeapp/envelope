class Envelope.Routers.Accounts extends Backbone.Router
  routes:
    'accounts': 'index'
    'accounts/new': 'new'

  initialize: ->
    @_initSidebar()

  index: ->
    @collection = new Envelope.Collections.Accounts()
    @collection.fetch()

    @collection.on 'reset', =>
      Backbone.history.navigate('accounts/new', trigger: true) if @collection.length == 0

    view = new Envelope.Views.AccountsIndex(collection: @collection)
    $('#container').html(view.render().el)

  new: (id) ->
    @model = new Envelope.Models.Account()
    @common_account_settings = new Envelope.Collections.CommonAccountSettings()
    @common_account_settings.fetch()

    view = new Envelope.Views.AccountsNew(model: @model, common_account_settings: @common_account_settings)
    $('#container').html(view.render().el)

  _initSidebar: ->
    @accounts = new Envelope.Collections.Accounts()
    @accounts.fetch()

    @sidebarView = new Envelope.Views.Sidebar(collection: @accounts)
    $('#sidebar').html(@sidebarView.render().el)
