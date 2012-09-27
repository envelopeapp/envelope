# This file is necessary because we use the Bonsai add-on on heroku. Please see
# https://gist.github.com/2041121 for more information.

if ENV['BONSAI_INDEX_URL']
  Tire.configure do
    url 'http://index.bonsai.io'
  end

  BONSAI_INDEX_NAME = ENV['BONSAI_INDEX_URL'][/[^\/]+$/]
else
  app_name = Rails.application.class.parent_name.underscore.dasherize
  app_env = Rails.env

  BONSAI_INDEX_NAME = "#{app_name}-#{app_env}"
end
