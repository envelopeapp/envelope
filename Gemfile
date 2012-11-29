source :rubygems

gem 'attr_encrypted'
gem 'bcrypt-ruby'
gem 'bootstrap_forms'
gem 'bson_ext'
gem 'chronic'
gem 'eco'
gem 'foreman'
gem 'gemoji', :git => 'git://github.com/sethvargo/gemoji' # need to use this until https://github.com/github/gemoji/pull/19 is merged
gem 'haml'
gem 'html-pipeline', :git => 'git://github.com/jch/html-pipeline'
gem 'jquery-rails'
gem 'kaminari'
gem 'magiconf'
gem 'mail', :require => false
gem 'mongoid'
gem 'mongoid-ancestry'
gem 'nokogiri', :require => false
gem 'nested_form', :git => 'git://github.com/ryanb/nested_form.git'
gem 'oj'
gem 'puma'
gem 'pusher'
gem 'rabl'
gem 'rails', '3.2.9'
gem 'sidekiq'
gem 'tire'
gem 'vcard', :require => false
gem 'warden'

# cancan needs to be last so it picks up the mongo driver
gem 'cancan'

# Sidekiq engine
group :sidekiq do
  gem 'sinatra', :require => false
  gem 'slim'
end

group :assets do
  gem 'coffee-rails', '~> 3.2.2'
  gem 'sass-rails', '~> 3.2.5'
  gem 'uglifier', '>= 1.3.0'
end

group :development do
  gem 'awesome_print'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'heroku'
  gem 'hirb'
  gem 'rb-fsevent'
  gem 'quiet_assets'
  gem 'terminal-notifier-guard'
  gem 'wirble'
  gem 'yard'
end

group :test, :developement do
  gem 'redcarpet'
end

group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'mongoid-rspec'
  gem 'rspec-rails'
  gem 'simplecov', :require => false
  gem 'spork'
  gem 'webmock', :require => false
end

group :production do
  gem 'daemons'
end
