class Envelope.Accounts

class Envelope.Accounts.Index extends Spine.Controller
  events:
    'click [data-type=edit]': 'edit'

  constructor: ->
    super
    @log 'Accounts Index View'
    Envelope.Account.bind 'refresh change', @render
    Envelope.Account.fetch()

  release: ->
    Envelope.unbind 'refresh change', @render

  render: =>
    accounts = Envelope.Account.all()
    console.log @view('accounts/index')(accounts: accounts)
    @html @view('accounts/index')(accounts: accounts)

  edit: (e) ->
    item = $(e.target).item()
    @navigate '/accounts', item.id, 'edit'

class Envelope.Accounts extends Spine.Stack
  className: 'stack accounts'

  controllers:
    index: Envelope.Accounts.Index

  routes:
    '/accounts': 'index'

  default: 'index'
