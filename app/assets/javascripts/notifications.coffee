class Notifications
  constructor: (app_key, user_id) ->
    @pusher = new Pusher(app_key)
    @channel = @pusher.subscribe "private-#{user_id}"

    @channel.bind 'pusher:subscription_error', (status) ->
      Flash.alert 'Could not authenticate to pusher!' if status == 403

    @channel.bind_all (event_name, data) =>
      unless event_name.match /pusher.*/
        try
          fn = event_name.replace /-/g, '_'
          console.log fn
          @[fn](data)
        catch error
          console.error "There is no handler for '#{event_name}' events!"

  account_worker_start: (data) ->
    $('.sidebar .sync').addClass 'rotate'

  account_worker_finish: (data) ->
    $('.sidebar .sync').removeClass 'rotate'

  mailbox_worker_start: (data) ->
    console.log data

@Notifications = Notifications
