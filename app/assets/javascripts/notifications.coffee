class Notifications
  constructor: (app_key, user_id) ->
    @pusher = new Pusher(app_key)
    @channel = @pusher.subscribe "private-#{user_id}"

    @channel.bind 'pusher:subscription_error', (status) ->
      Flash.alert 'Could not authenticate to pusher!' if status == 403

    @channel.bind_all (event_name, data) =>
      unless event_name.match /pusher.*/
        fn = event_name.replace /-/g, '_'
        if @[fn]?
          @[fn](data)
        else
          console.error "There is no handler for '#{fn}' events!"

  account_worker_start: (data) ->
    $('.sidebar .sync').addClass 'rotate'

  account_worker_finish: (data) ->
    $('.sidebar .sync').removeClass 'rotate'

  mailbox_worker_start: (data) ->
    $mailbox = @_get_mailbox(data.mailbox.id)
    if $mailbox.length > 0
      $mailbox.addClass 'loading'

  mailbox_worker_finish: (data) ->
    $mailbox = @_get_mailbox(data.mailbox.id)
    if $mailbox.length > 0
      $mailbox.removeClass 'loading'

  mapping_worker_finish: (data) ->
    # TODO: redraw with JS
    location.reload()

  message_sender_worker_finish: (data) ->
    Flash.info 'Your message was sent!'

  message_update_worker_start: (data) ->
    $mailbox = @_get_mailbox(data.mailbox.id)
    if $mailbox.length > 0
      $mailbox.addClass 'loading'

  message_update_worker_finish: (data) ->
    $mailbox = @_get_mailbox(data.mailbox.id)
    if $mailbox.length > 0
      $mailbox.removeClass 'loading'
      if $mailbox.hasClass 'active'
        $mailbox.click()
        Flash.info "<strong>#{data.mailbox.name}</strong> is now up to date!"

  message_worker_start: (data) ->
    $mailbox = @_get_mailbox(data.mailbox.id)
    if $mailbox.length > 0
      $mailbox.addClass 'loading'

  message_worker_finish: (data) ->
    $mailbox = $mailbox = $(".sidebar .mailboxes a[data-mailbox-id='#{data.mailbox.id}']")
    if $mailbox.length > 0
      $mailbox.removeClass 'loading'
      if $mailbox.hasClass 'active'
        $mailbox.click()
        Flash.info "<strong>#{data.mailbox.name}</strong> is now up to date!"

  _get_mailbox: (mailbox_id) ->
    $(".sidebar .mailboxes a[data-mailbox-id='#{mailbox_id}']")

@Notifications = Notifications
