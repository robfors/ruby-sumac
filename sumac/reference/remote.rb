module Sumac
  module Reference
    class Remote
      
      attr_reader :exposed_id, :remote_object
      
      def initialize(connection, exposed_id)
        raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
        @connection = connection
        raise unless exposed_id.is_a?(Integer)
        @exposed_id = exposed_id
        @remote_object = RemoteObject.new(connection, self)
      end
      
    end
  end
end
