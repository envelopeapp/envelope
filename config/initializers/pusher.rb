# Pusher configuration
# Parse the envelope.yml configuration file and read the pusher config. If we are on
# heroku, we don't actually want to do anything...

unless Rails.env.test?
  begin
    config = YAML.load(ERB.new(File.read(Rails.root.join('config/envelope.yml'))).result)[Rails.env]

    if config && config['pusher']
      unless config['pusher']['heroku']
        require 'pusher'

        Pusher.logger = Rails.logger
        Pusher.app_id = config['pusher']['app_id']
        Pusher.key = config['pusher']['key']
        Pusher.secret = config['pusher']['secret']
      end
    end
  rescue
    Rails.logger.warn('Could not load envelope config. Skipping Pusher config.')
  end
end
