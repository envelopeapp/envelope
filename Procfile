web:        bundle exec rails server thin -p $PORT -e $RACK_ENV
faye:       rackup ./private_pub.ru -s thin -E production
job:        bundle exec rake jobs:work
solr:       bundle exec rake sunspot:solr:run
solr_test:  bundle exec rake sunspot:solr:run RAILS_ENV=test
guard:      bundle exec guard
