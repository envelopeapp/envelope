$ ->
  #
  # Clicking on a sidebar label should show the messages with that label
  #
  $('.sidebar-label').live 'click', (e) ->
    e.preventDefault()

    $this = $(@)

    $this.toggleClass('active')
    $('.sidebar-mailbox').removeClass('active')

    label_ids = []
    for label in $('.sidebar-label.active')
      label_ids.push(label.getAttribute('data-label-id'))

    $.ajax
      url: Routes.labels_messages_path()
      dataType: 'json'
      contentType: 'json'
      data: { 'label_ids[]': label_ids }
      success: (messages) ->
        Render.messages(messages)

  #
  # Dragging a sidebar label
  #
  $('.sidebar-label').draggable
    appendTo:'body'
    cursor:'move'
    cursorAt:
      bottom: -5
      right: -5
    helper: ->
      $this = $(this)
      classes = $this.find('.label').attr('class')
      text = $this.find('.label-name').html()
      return $this.clone().attr('class', classes).html(text)


  #
  # Dropping a .message onto a sidebar label should add that message to that label
  #
  $('.sidebar-label').droppable
    accept: '.message'
    hoverClass: 'hover'
    drop: (e, ui) ->
      $message = $(ui.draggable)
      $label = $(e.target)

      label_ids = $.makeArray($message.find('.label')).map (l) -> $(l).attr('data-label-id')
      unless $label.attr('data-label-id') in label_ids
        $.post("#{$message.attr('href')}/toggle_label", { label_id:$label.attr('data-label-id') })


  #
  # Override the bootstrap default dropdown delegation so that we can have
  # a dropdown checkbox list
  #
  $('.dropdown-menu.label-dropdown a').live 'hover', (e) ->
    $(this).unbind 'click'
    $(this).bind 'click', (e) ->
      # this prevents the dropdown from closing on click
      e.stopPropagation()
      e.preventDefault()

      $this = $(this)
      $this.toggleClass('checked')

      # make a post request (private pub will handle the publishing)
      $.post($this.attr('href'), { label_id:$this.attr('data-label-id') })