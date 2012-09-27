#= require jquery
#= require jquery-ui
#= require jquery_ujs

#= require jquery_nested_form
#= require js-routes

#= require_tree ./lib
#=/ require_tree ./views
#=/ require_tree ./helpers

#= require app
#=/ require accounts
#=/ require contacts
#=/ require labels
#=/ require messages
#=/ require private_pub_handler
#=/ require sidebar
#=/ require topbar

#=/ require_self

$ ->
  new Envelope();

  $('body').tooltip
    selector: '[rel=tooltip]'
    delay:
      show: 200
      hide: 100

  $('[rel=tooltip]').live 'click', ->
    $(@).tooltip('hide')
