# Override the to_json method for BSON:ObjectId for serialization
module Moped
  module BSON
    class ObjectId
      def to_json(*args)
        to_s.to_json
      end
    end
  end
end
