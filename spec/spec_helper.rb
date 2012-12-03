require 'spork'

Spork.prefork do
  # Disable Tire
  require 'support/tire/disable'

  # Load the Environment
  ENV['RAILS_ENV'] ||= 'test'
  require File.expand_path('../../config/environment', __FILE__)

  # Require necessary gems
  require 'factory_girl'
  require 'rspec/rails'
  require 'rspec/mocks'
  require 'sidekiq/testing'
  require 'webmock/rspec'

  # Support files
  Dir[Rails.root.join('spec/support/**/*.rb')].each{ |f| require f }

  # Make RSpec exceptions look nicer
  alias :running :lambda

  # RSpec Config
  RSpec.configure do |config|
    config.mock_with :rspec

    ActiveSupport::Dependencies.clear

    # Factory Girl
    config.include FactoryGirl::Syntax::Methods

    # Mongoid
    config.include Mongoid::Matchers

    config.before(:each) do
      # Elastic Search Mock
      stub_request(:any, %r|#{Tire::Configuration.url}.*|)
        .to_return(status: 200, body: '{"took": 1,"timed_out": false,"_shards": {"total": 5,"successful": 5,"failed": 0},"hits": {"total": 0,"max_score": null,"hits": []}}', headers: {})
    end

    config.after(:each) do
      # Database Cleaner
      Mongoid.purge!
    end
  end
end

Spork.each_run do
  # require 'simplecov'
  # SimpleCov.start 'rails'

  load "#{Rails.root}/config/routes.rb"
  Dir["#{Rails.root}/app/**/*.rb"].each {|f| load f}
  Dir["#{Rails.root}/lib/**/*.rb"].each {|f| load f}
end
