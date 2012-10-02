class Envelope.Topbar extends Spine.Controller
  constructor: ->
    super
    @render()

  events:
    'click #manage-accounts-button': 'show_accounts'

  render: =>
    @html @view('topbar/main')(@)

  show_accounts: (e) ->
    e.preventDefault()
    @navigate('/accounts') # WTF?
