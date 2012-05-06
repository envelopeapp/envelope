# These are handlers for subscriptions from PrivatePub

class PrivatePubHandler
  constructor: (@queue) ->
    PrivatePub.subscribe @queue, (data, channel) =>
      # send the action with the data
      @[data.action](data)

  #
  # Tells the front-end that we are currently loading mailboxes
  #
  # Fires when:
  #   - mailboxes are loading
  #   - account is being synced
  #   - progress bar
  #
  loading_mailboxes: (data) ->
    account = data.account
    $progressBar = $('div.progress#' + account.slug + ' .bar')
    $progressBar.css({width:'5%'})

    $('.sidebar .sync').addClass('rotate')

  #
  # Tells the front-end that we loaded a single mailbox
  #
  # Fires when:
  #   - a mailbox is created/updated
  #   - the user syncs an account
  #
  loaded_mailbox: (data) ->
    mailbox = data.mailbox
    account = data.account

    # update the progress bar
    $progressBar = $(".progress[data-account-id=#{account.slug}] .bar")
    $progressBar.css({ width: "#{data.percent_complete}%" })

    # update the status text
    $statusText = $(".status[data-account-id=#{account.slug}]")
    $statusText.html("Loaded #{mailbox.name}...")

  #
  # Tells the front-end that we loaded all the mailboxes
  #
  # Fires when:
  #   - all mailboxes have been loaded
  #   - syncing account
  #
  loaded_mailboxes: (data) ->
    account = data.account

    # update the progress bar
    $progressBar = $(".progress[data-account-id=#{account.slug}] .bar")
    $progressBar.css({ width:'100%' })

    # update the status text
    $statusText = $(".status[data-account-id=#{account.slug}]")
    $statusText.html("Done!")

    $('.sidebar .sync').removeClass('rotate')

    if $progressBar.length
      window.location = Routes.unified_mailbox_messages_path('inbox')

  #
  # Tells the front-end that we have loaded new messages for a given mailbox
  #
  # Fires when:
  #   - a mailbox messages have begun to load
  #
  loading_messages: (data) ->
    $(".sidebar .sidebar-mailbox[data-mailbox-id=#{data.mailbox.slug}]").addClass('loading')

  #
  # Tells the front-end that we have finished loading new messages for the given mailbox. If
  # the messages are from the currently selected mailbox, we should update the messages.
  #
  # Fires when:
  #   - a mailbox has completed loading all messages
  #
  loaded_messages: (data) ->
    mailbox = data.mailbox
    account = mailbox.account
    $left_pane = $('.left-pane')

    # if we are looking at the active mailbox
    if $(".sidebar-mailbox[data-mailbox-id=#{mailbox.slug}]").hasClass('active')
      # make a remote call to get all the new messages
      $left_pane.html('')
      $left_pane.addClass('loading')
      $.getJSON Routes.account_mailbox_messages_path(account.slug, mailbox.slug), (messages) ->
        Render.messages(messages)

    # remove the loading class(es)
    $(".sidebar .sidebar-mailbox[data-mailbox-id=#{mailbox.slug}]").removeClass('loading')


  #
  # Tells the front-end that we have started to load message bodies. This is the process of
  # actually parsing the message and making it format correctly, so it can take some time
  #
  # Fires when:
  #   - a batch loading of message bodies has begun
  #
  loading_message_bodies: (data) ->
    Flash.info('Loading message bodies...')

  #
  # Tells the front-end that a particular message has been loaded. If that message is currently
  # showing on screen, we need to update the view so the message is no longer "loading"
  #
  # Fires when:
  #   - a message body has been fully loaded
  #
  loaded_message_body: (data) ->
    message = data.message
    $message = $(".left-pane .message[data-message-id=#{message.id}]")
    if $message
      $message.replaceWith(JST['views/messages/_message']({ message:message }))

  #
  # Tells the front-end that we are no longer loading message bodies
  #
  # Fires when:
  #   - all message bodies have been loaded
  #
  loaded_message_bodies: (data) ->
    Flash.info('Loaded message bodies')


  #
  # Updates the number of unread messages in the sidebar when messages are changed
  #
  # Fires when:
  #   - a message is marked as read
  #   - a message is marked as unread
  #
  update_unread_messages_counter: (data) ->
    mailbox = data.mailbox

    $mailbox_line = $(".sidebar a[data-mailbox-id=#{mailbox.slug}]")
    $mailbox_line.find('.unread-messages-counter').remove()

    unless mailbox.unread_messages == 0
      $mailbox_line.append(JST['views/mailboxes/_unread_messages_counter']({ count:mailbox.unread_messages }))


  #
  # Updates the front-end and adds appropiate labels
  #
  # Fires when:
  #   - a label is added to a message
  #
  added_label: (data) ->
    label = data.label
    message = data.message

    $message_left_labels = $(".left-pane .message[data-message-id=#{message.id}] .message-labels")
    $message_left_labels.append(JST['views/labels/_label']({ label:label }))

    $message_right_labels = $(".right-pane .message[data-message-id=#{message.id}] .message-labels")
    $message_right_labels.append(JST['views/labels/_label']({ label:label }))


  #
  # Updates the front-end and removes labels where they exist
  #
  # Fires when:
  #   - a label is removed from a message
  #
  removed_label: (data) ->
    label = data.label
    message = data.message

    $(".message[data-message-id=#{message.id}] .label[data-label-id=#{label.id}]").remove()


  #
  # Throws an error
  #
  # Fires when:
  #   - something bad happends
  #
  error: (data) ->
    Flash.alert(data.message)


  #
  # There is a notice
  #
  # Fires when:
  #   - the backend sends some kind of message to the front-end
  #
  notice: (data) ->
    Flash.info(data.message)


# export to the global namespace
window.PrivatePubHandler = PrivatePubHandler