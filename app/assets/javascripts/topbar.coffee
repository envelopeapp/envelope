$ ->
  # SEARCH messages
  timer = null
  $('input#search-box').keyup (e) ->
    $input = $(@)

    clearTimeout(timer) if timer?

    timer = setTimeout ->
      # fire off the ajax request
      $.ajax
        url: $input.attr('data-search-path')
        dataType: 'json'
        contentType: 'json'
        data: {
          q: $input.val()
        }
        success: (messages) ->
          Render.messages(messages)
        failure: (error) ->
          Flash.alert(error)
    , 400