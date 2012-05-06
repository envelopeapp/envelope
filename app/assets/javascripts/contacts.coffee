$ ->
  # DELETE a contact
  $('#delete-button')
    .live 'ajax:success', (data, status, xhr) ->
      $this = $(this)
      $contact = $this.parents('.contact')
      $arrow = $('.bubble-arrow')
      contactId = $contact.attr('data-contact-id')

      $contact.remove()
      $('.left-pane .contact[data-contact-id='+contactId+']').fadeOut 'fast', ->
        $(this).next().click()
        $(this).remove()
        $arrow.hide()
    .live 'ajax:error', (xhr, status, error) ->
      Flash.alert(error)

  $('.left-pane .contact').live 'click', (e) ->
    e.preventDefault()

    # grab this
    $this = $(this)

    # remove existing selected class(es)
    $('.left-pane .contact.selected').removeClass('selected')

    # select this contact
    $this.addClass('selected')

    url = $(this).attr('href')

    # grab the contact pane and arrow
    $contactPane = $('#contact-pane')
    $arrow = $('.bubble-arrow')

    $contactPane.fadeOut 'fast', ->
      $.ajax
        url: url
        dataType: 'json'
        success: (contact) ->
          html = JST['views/contacts/show']({ contact:contact })
          $contactPane.html(html)
          $contactPane.css({ marginTop:$this.position().top - 20 + 'px' })

          $arrow.css({ top:$this.position().top - 12 + 'px'})
          $arrow.show()

          $contactPane.fadeIn 'fast', ->
            $('.content').animate({scrollTop: $this.position().top - 20 + 'px'}, 500)
        failure: (data) ->
          alert data