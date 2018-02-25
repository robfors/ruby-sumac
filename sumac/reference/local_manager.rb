module Sumac
  module Reference
    class LocalManager
      
      def initialize(connection)
        raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
        @connection = connection
        @id_allocator = IDAllocator.new
        @exposed_id_table = {}
        @global_id_table = {}
        @semaphore = Mutex.new
      end
      
      def retrieve(exposed_id)
        raise unless exposed_id.is_a?(Integer)
        reference = @semaphore.synchronize { @exposed_id_table[exposed_id] }
        reference
      end
      
      def load(exposed_object)
        raise unless exposed_object.is_a?(ExposedObject)
        reference = @semaphore.synchronize { find(exposed_object) || create(exposed_object) }
        reference
      end
      
      private
      
      def find(exposed_object)
        reference = @global_id_table[exposed_object.__global_sumac_id__]
        reference
      end
      
      def create(exposed_object)
        new_exposed_id = @id_allocator.allocate
        new_reference = Local.new(@connection, new_exposed_id, exposed_object)
        @exposed_id_table[new_exposed_id] = new_reference
        @global_id_table[exposed_object.__global_sumac_id__] = new_reference
        new_reference
      end
      
    end
  end
end
