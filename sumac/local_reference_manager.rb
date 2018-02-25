module Sumac
  class LocalReferenceManager
    
    def initialize(connection)
      @semaphore = Mutex.new
      @connection = connection
      @id_allocator = IDAllocator.new
      @id_table = {}
      @global_id_table = {}
    end
    
    def get(id)
      raise 'ID is not valid' unless @id_allocator.valid?(id)
      semaphore.synchronize do
        entry = @id_table[id]
      end
      raise: 'object has been forgotten' unless entry #make better exception
      return entry
    end
    
    def find_or_create(exposed_object)
      find(exposed_object) or create(exposed_object)
    end
    
    def create(exposed_object)
      new_id = @id_allocator.allocate
      new_entry = LocalObjectReference.new(@connection, new_id, exposed_object)
      semaphore.synchronize do
        @id_table[new_entry.id] = new_entry
        @global_id_table[new_entry.exposed_object.__global_sumac_id__] = new_entry
      end
      return new_entry
    end
    
    def find(exposed_object)
      semaphore.synchronize do
        existing_entry = @global_id_table[exposed_object.__global_sumac_id__]
      end
    end
    
  end
end
