class Envelope.Topbar extends Spine.Controller
  constructor: ->
    super
    @render()

  render: =>
    @html @view('topbar/main')(@)
