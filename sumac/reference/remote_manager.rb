module Sumac
  module Reference
    class RemoteManager
      
      def initialize(connection)
        raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
        @connection = connection
        @exposed_id_table = {}
        @semaphore = Mutex.new
      end
      
      def find_or_create(exposed_id)
        raise unless exposed_id.is_a?(Integer)
        reference = @semaphore.synchronize { find(exposed_id) || create(exposed_id) }
      end
      
      def load(remote_object)
        raise unless remote_object.is_a?(RemoteObject)
        reference = remote_object.__remote_reference__
        reference
      end
      
      private
      
      def create(new_exposed_id)
        new_reference = Remote.new(@connection, new_exposed_id)
        @exposed_id_table[new_exposed_id] = new_reference
        new_reference
      end
      
      def find(exposed_id)
        reference = @exposed_id_table[exposed_id]
        reference
      end
      
    end
  end
end
