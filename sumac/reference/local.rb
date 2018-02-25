module Sumac
  module Reference
    class Local
    
      attr_reader :exposed_id, :exposed_object
      
      def initialize(connection, exposed_id, exposed_object)
        raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
        @connection = connection
        raise unless exposed_id.is_a?(Integer)
        @exposed_id = exposed_id
        @exposed_object = exposed_object
      end
      
    end
  end
end
