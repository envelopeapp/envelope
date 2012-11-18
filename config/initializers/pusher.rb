if Envelope::Config.pusher
  Pusher.app_id = Envelope::Config.pusher['app_id']
  Pusher.key = Envelope::Config.pusher['key']
  Pusher.secret = Envelope::Config.pusher['secret']
  Pusher.logger = Rails.logger
end
