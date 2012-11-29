$ ->
  # DELETE a message
  $('#delete-button')
    .live 'ajax:success', (data, status, xhr) ->
      $this = $(@)
      $message = $this.parents('.message')
      $arrow = $('.bubble-arrow')
      messageId = $message.attr('data-message-id')

      $message.remove()
      $('.left-pane .message[data-message-id='+messageId+']').fadeOut 'fast', ->
        $(this).next().click()
        $(this).remove()
        $arrow.hide()
    .live 'ajax:error', (xhr, status, error) ->
      Flash.alert(error)

  # FLAG a message
  $('#flag-button')
    .live 'ajax:success', (data, status, xhr) ->
      $this = $(this)
      $message = $this.parents('.message')
      messageId = $message.attr('data-message-id')

      $leftMessage = $('.left-pane .message[data-message-id='+messageId+']')

      if data.flagged == true
        $leftMessage.find('.bubble-metadata').append('<i class="icon icon-flag"></i>')
      else if data.flagged == false
        $leftMessage.find('.icon.icon-flag').remove()

  # UNREAD a message
  $('#unread-button')
    .live 'ajax:success', (data, status, xhr) ->
      $this = $(this)
      $message = $this.parents('.message')
      messageId = $message.attr('data-message-id')
      $this.remove()

      $leftMessage = $('.left-pane .message[data-message-id='+messageId+']')
      $leftMessage.addClass('unread')
    .live 'ajax:error', (xhr, status, error) ->
      Flash.alert(error)


  # SHOW a message
  $('.left-pane .message').live 'click', (e) ->
    e.preventDefault()

    # grab this
    $this = $(this)

    # remove existing selected class(es)
    $('.left-pane .message.selected').removeClass('selected')

    # select this message and "unread it"
    $this.addClass('selected').removeClass('unread')

    # grab the message pane and arrow
    $messagePane = $('#message-pane')
    $arrow = $('.bubble-arrow')

    url = $(this).attr('href')
    $messagePane.fadeOut 'fast', ->
      $.ajax
        url: url
        dataType: 'json'
        success: (data) ->
          html = JST['views/messages/show'](message: data)
          $messagePane.html(html)
          $messagePane.css({ marginTop:$this.position().top - 20 + 'px' })

          $arrow.css({ top:$this.position().top + 13 + 'px'})
          $arrow.show()

          $messagePane.fadeIn 'fast', ->
            $('.content').animate({scrollTop: $this.position().top - 20 + 'px'}, 500)
        failure: (message) ->
          alert message

  # contact search
  cache = {}
  $('form#new_message input.contact-search')
  # don't navigate away from the field on tab when selecting an item
  .bind 'keydown', (e) ->
    if e.keyCode == $.ui.keyCode.TAB && $(this).data('autocomplete').menu.active
      e.preventDefault();
  .autocomplete
    source: (request, response) ->
      term = request.term;
      if term in cache
        response(cache[term])
        return

      lastXhr = $.getJSON '/search/contacts', { term: extractLast(request.term) }, (data, status, xhr) ->
        cache[term] = data
        if xhr == lastXhr
          response(data)
    search: ->
      # custom minLength
      term = extractLast(this.value)
      return false if term.length < 1
    focus: ->
      false
    select: (e, ui) ->
      terms = split(this.value);
      # remove the current input
      terms.pop();
      # add the selected item
      terms.push( ui.item.value );
      # add placeholder to get the comma-and-space at the end
      terms.push('');
      this.value = terms.join(', ');

      false;
  .each ->
    $(this).data('autocomplete')._renderItem = (ul, item) ->
      re = new RegExp(extractLast(this.term), 'ig')
      newLabel = item.label.replace(re, '<strong>' + '$&' + '</strong>')
      return $('<li></li>').data('item.autocomplete', item).append('<a>' + newLabel + '</a>').appendTo(ul);

  # SCROLLING
  $('.content').scroll ->
    $messages = $('.left-pane.messages')
    if $messages.length
      loading = $messages.attr('data-loading') == 'true'
      loaded = $messages.attr('data-loaded') == 'true'

      if !loading && !loaded && $('.content').scrollTop() + $('.content').outerHeight() >= $('.content')[0].scrollHeight - 50
        $messages.attr('data-loading', 'true')

        page = Number($messages.attr('data-page') || 1) + 1
        $messages.attr('data-page', page)

        if $('#search-box').val().length
          url = $('#search-box').attr('data-search-path')
        else
          url = window.location.href

        $.ajax
          url: url
          contentType: 'json'
          dataType: 'json'
          data: { page: page, q: $('#search-box').val() }
          success: (messages) ->
            $messages.attr('data-loading', 'false')
            if messages.length == 0
              $messages.attr('data-loaded', 'true')
            else
              for message in messages
                $messages.append(JST['views/messages/_message']({ message:message }))

  #
  # HELPER functions
  #
  split = (val) ->
    val.split(/,\s*/)

  extractLast = (term) ->
    split(term).pop()
