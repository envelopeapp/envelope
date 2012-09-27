$ ->
  #
  # Clicking on a sidebar title/subtitle toggles expand/collapse the mailbox group
  #
  $('.sidebar-title.arrow, .sidebar-subtitle.arrow').live 'click', ->
    $(@).next().slideToggle 100, =>
      $(@).toggleClass('closed')


  #
  # Clicking on the sync mailboxes button should trigger a remote server sync
  #
  $('#sidebar .sync').live 'click', (e) ->
    e.preventDefault()
    $(@).addClass('rotate')
    $.get($(@).attr('href'))


  #
  # Dragging a message onto a sidebar should only work for a selectable mailbox
  # and a mailbox that is associated with the current account (for now)
  #
  $('#sidebar .mailboxes a.sidebar-mailbox.selectable').droppable
    addClasses: false
    accept: (draggable) ->
      # only accept messages from the existing account for now
      draggable_account_id = draggable.attr('data-account-id')
      $(@).parents('.mailboxes').first().attr('data-account-id') == draggable_account_id
    hoverClass: 'hover'
    drop: (e, ui) ->
      $message = $(ui.draggable)
      $mailbox = $(e.target)

      Flash.success('<strong>Success!</strong> You moved the message. Unfortunately this feature is still in development and not full functional')


  #
  # Clicking on a mailbox triggers a remote server call
  #
  $('#sidebar .mailboxes a.sidebar-mailbox').live 'click', (e) ->
    e.preventDefault()

    # get this
    $this = $(@)

    return unless $this.hasClass('selectable')

    # reset search box
    $('#search-box').val('')

    # reset labels
    $('.sidebar-label').removeClass('active')

    # only get mailboxes that are selectable
    if $this.attr('href').indexOf('void') == -1
      # show the right mailbox is selected
      $('#sidebar .mailboxes a.sidebar-mailbox').removeClass('active')
      $this.addClass('loading active')

      $.ajax
        url: $this.attr('href')
        contentType: 'json'
        dataType: 'json'
        success: (messages) ->
          Render.messages(messages)
          $this.removeClass('loading')
          history.pushState({ mailbox_id:$this.attr('data-mailbox-id') }, "", $this.attr('href'))
        error: (error) ->
          Render.messages(null)
          $this.removeClass('loading')
