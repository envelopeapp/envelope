source :rubygems
ruby '1.9.3'

gem 'mongoid-ancestry'
gem 'bcrypt-ruby'
gem 'bootstrap_forms'
gem 'bson_ext'
gem 'chronic'
gem 'delayed_job_mongoid'
gem 'eco'
gem 'foreman'
gem 'haml'
gem 'jquery-rails'
gem 'js-routes'
gem 'kaminari'
gem 'mail'
gem 'mongoid'
gem 'nested_form', :git => 'git://github.com/ryanb/nested_form.git'
gem 'puma'
gem 'pusher'
gem 'rabl'
gem 'rails', '3.2.8'
gem 'rails-api'
gem 'spine-rails'
gem 'tire'
gem 'vcard'
gem 'warden'
gem 'yajl-ruby', :require => 'yajl/json_gem'

# cancan needs to be last so it picks up the mongo driver
gem 'cancan'

group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'sass-rails', '~> 3.2.3'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'heroku'
  gem 'quiet_assets'
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
