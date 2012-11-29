begin
  require 'tire'

  namespace :elasticsearch do
    desc 'Clear all elasticsearch indicies'
    task :clear do
      indicies = Oj::Doc.parse(Tire::Configuration.client.get("#{Tire::Configuration.url}/_aliases").body).keys

      indicies.each do |index|
        index = Tire::Index.new index
        index.delete
      end
    end
  end
rescue LoadError
  $stderr.puts 'Could not load tire - is it in your Gemfile?'
end
