class Envelope.Accounts extends Spine.Controller
  events:
    'change input': 'close'

  constructor: ->
    super

    @routes
      '/accounts': @index

    Envelope.Account.bind 'refresh change', @render

  index: ->
    @render()

  render: =>
    accounts = Envelope.Account.all()
    @html @view('accounts/index')(accounts: accounts)

  close: ->
    console.log @
