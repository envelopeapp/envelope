require 'spork'

Spork.prefork do
  ENV['RAILS_ENV'] ||= 'test'
  require File.expand_path('../../config/environment', __FILE__)

  # Require necessary gems
  require 'factory_girl'
  require 'rspec/rails'
  require 'rspec/mocks'
  require 'webmock/rspec'

  # Support files
  Dir[Rails.root.join('spec/support/**/*.rb')].each{ |f| require f }
end

Spork.each_run do
  require 'simplecov'
  SimpleCov.start 'rails'

  load "#{Rails.root}/config/routes.rb"
  Dir["#{Rails.root}/app/**/*.rb"].each {|f| load f}
  Dir["#{Rails.root}/lib/**/*.rb"].each {|f| load f}

  # RSpec Config
  RSpec.configure do |config|
    config.mock_with :rspec

    ActiveSupport::Dependencies.clear

    # Factory Girl
    config.include FactoryGirl::Syntax::Methods

    # Mongoid
    config.include Mongoid::Matchers

    config.before do
      # Delayed Job
      Delayed::Job.stub!(:enqueue).and_return(nil)

      # Elastic Search Mock
      stub_request(:any, %r|#{Tire::Configuration.url}.*|)
        .to_return(status: 200, body: '{"took": 1,"timed_out": false,"_shards": {"total": 5,"successful": 5,"failed": 0},"hits": {"total": 0,"max_score": null,"hits": []}}', headers: {})

      # Faye Mock
      stub_request(:any, %r|#{PrivatePub.config[:server]}.*|)
        .to_return(status: 200, body: '', headers: {})
    end

    config.after(:each) do
      # Database Cleaner
      Mongoid.purge!
    end
  end
end
