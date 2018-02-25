class Sumac
  class LocalReferences
  
    def initialize(connection)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @id_allocator = IDAllocator.new
      @exposed_id_table = {}
      @native_id_table = {}
      @transaction = []
    end
    
    def detach
      @exposed_id_table.values.each { |reference| reference.detach }
    end
    
    def destroy
      @exposed_id_table.values.each { |reference| reference.destroy }
    end
    
    def from_id(exposed_id)
      raise unless @id_allocator.valid?(exposed_id)
      reference = @exposed_id_table[exposed_id]
      reference
    end
    
    def from_object(exposed_object)
      raise unless exposed_object.is_a?(ExposedObject)
      reference = find(exposed_object) || create(exposed_object)
      reference
    end
    
    def remove(reference)
      @exposed_id_table.delete(reference.exposed_id)
      references = @native_id_table[native_id(reference.exposed_object)]
      references.delete(reference)
      @native_id_table.delete(native_id(reference.exposed_object)) if references.empty?
      @id_allocator.free(reference.exposed_id)
    end
    
    def rollback_transaction
      @transaction.each { |reference| reference.quiet_forget }
      @transaction = []
    end
    
    def commit_transaction
      @transaction = nil
    end
    
    def start_transaction
      @transaction = []
    end
    
    private
    
    def create(exposed_object)
      new_exposed_id = @id_allocator.allocate
      new_reference = LocalReference.new(@connection, new_exposed_id, exposed_object)
      @exposed_id_table[new_exposed_id] = new_reference
      references = @native_id_table[native_id(exposed_object)]
      if references
        references << new_reference
      else
        @native_id_table[native_id(exposed_object)] = [new_reference]
      end
      @transaction << new_reference if @transaction
      new_reference
    end
    
    def find(exposed_object)
      references = @native_id_table[native_id(exposed_object)]
      return nil unless references
      callable_references = references.select { |reference| reference.callable? }
      raise if callable_references.length > 1
      reference = callable_references.first
      reference
    end
    
    def native_id(exposed_object)
      exposed_object.__id__
    end
    
  end
end
