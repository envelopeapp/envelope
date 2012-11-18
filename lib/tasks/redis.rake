begin
  require 'redis'

  namespace :redis do
    desc 'Clear redis queue'
    task :clear do
      r = Redis.new
      r.keys.each do |key|
        r.del(key)
      end
    end
  end
rescue LoadError
  $stdout.puts 'Could not load redis - is it in your Gemfile?'
end
