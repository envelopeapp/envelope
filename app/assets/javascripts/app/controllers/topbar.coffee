class Envelope.Topbar extends Spine.Controller
  constructor: ->
    super
    @render()

  events:
    'click #manage-accounts-button': (e) ->
      e.preventDefault() && Spine.Route.navigate('/accounts')

  render: =>
    @html @view('topbar/main')(@)
