#= require jquery
#= require jquery-ui
#= require jquery_ujs

#= require jquery_nested_form
#= require js-routes

#= require_tree ./lib
#= require_tree ./views
#= require_tree ./helpers

#= require accounts
#= require contacts
#= require labels
#= require messages
#= require sidebar
#= require topbar

#= require_self

$ ->
  $('body').tooltip
    selector: '[rel=tooltip]'
    delay:
      show: 200
      hide: 100

  $('[rel=tooltip]').live 'click', ->
    $(@).tooltip('hide')

  #
  # onpopstate() handler
  # This method is fired when the user initially loads the page + when the back
  # button is triggered (either programatically or via the user)
  #
  # Fires when:
  #   - pages loads
  #   - back button triggers
  #   - programatic back button triggers
  #
  $(window).bind 'popstate', (e) ->
    mailbox_id = e.originalEvent.state?.mailbox_id || location.href.split('/').slice(-2)[0]

    if e.originalEvent.state?
      # we have the mailbox_id in popstate state
      mailbox_id = e.originalEvent.state.mailbox_id
    else if window.location.href.match /(inbox|sent|trash)/
      # its a "special" mailbox
      mailbox_id = window.location.href.split('/').slice(-1)[0]
    else
      # it's just a regular mailbox
      mailbox_id = window.location.href.split('/').slice(-2)[0]

    if mailbox_id?
      $('.sidebar .mailboxes a.sidebar-mailbox').removeClass('active')
      $sidebarMailbox = $(".sidebar .mailboxes a.sidebar-mailbox[data-mailbox-id=#{mailbox_id}]")
      $sidebarMailbox.addClass('loading active')

      $.ajax
        url: location.href
        contentType: 'json'
        dataType: 'json'
        success: (messages) ->
          Render.messages(messages)
          $sidebarMailbox.removeClass('loading')
        failure: (error) ->
          Flash.alert(error)
