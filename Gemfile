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
gem 'mail'
gem 'mongoid'
gem 'nested_form', :git => 'git://github.com/ryanb/nested_form.git'
gem 'puma'
gem 'private_pub'
gem 'rails', '3.2.8'
gem 'thin'
gem 'tire'
gem 'vcard'
gem 'warden'
gem 'will_paginate'
gem 'yajl-ruby', :require => 'yajl/json_gem'

# cancan needs to be last so it picks up the mongo driver
gem 'cancan'

group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'sass-rails', '~> 3.2.3'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
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
  gem 'simplecov'
  gem 'spork'
  gem 'webmock'
end

group :production do
  gem 'daemons'
end
