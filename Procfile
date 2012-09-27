web:      bundle exec rails server puma -p $PORT -e $RACK_ENV
faye:     rackup ./private_pub.ru -s thin -E production
worker:   bundle exec rake jobs:work
search:   elasticsearch -f -D es.config=./config/elasticsearch.yml
