#= require json2
#= require jquery
#= require spine
#= require spine/relation
#= require spine/manager
#= require spine/ajax
#= require spine/route

#= require_tree ./lib
#= require_self
#= require_tree ./helpers
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views

class Envelope extends Spine.Controller
 constructor: ->
    super

    new Envelope.Topbar(el: $('#topbar'))
    new Envelope.Sidebar(el: $('#sidebar'))
    new Envelope.Accounts(el: $('#accounts'))
    # new Envelope.Sessions(el: $('#login'))

    Spine.Route.setup(history: true)

window.Envelope = Envelope
