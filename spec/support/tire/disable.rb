# Since the `mapping` method is a class method, Tire will try to contact the
# ElasticSearch server on app initialization. This sucks, because we need the
# app initialized to stub the request. So let's just ignore indexes in testing.

require 'tire'
module ::Tire::Model::Indexing::ClassMethods
  def mapping; end
end
