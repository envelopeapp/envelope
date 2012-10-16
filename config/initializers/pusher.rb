# Pusher configuration
# Parse the envelope.yml configuration file and read the pusher config. If we are on
# heroku, we don't actually want to do anything...

pusher_config = Rails.application.config.envelope['pusher']
if pusher_config
  unless pusher_config['heroku']
    require 'pusher'
    Pusher.logger = Rails.logger
    Pusher.app_id = pusher_config['app_id']
    Pusher.key = pusher_config['key']
    Pusher.secret = pusher_config['secret']
  end
end
