class Sumac
  class RemoteReferences
  
    def initialize(connection)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @exposed_id_table = {}
      @transaction = []
    end
    
    def detach
      each { |reference| reference.detach }
    end
    
    def destroy
      each { |reference| reference.destroy }
    end
    
    def from_id(exposed_id)
      raise unless IDAllocator.valid?(exposed_id)
      reference = find(exposed_id) || create(exposed_id)
    end
    
    def from_object(remote_object)
      raise unless remote_object.is_a?(RemoteObject)
      reference = remote_object.__remote_reference__
      raise StaleObjectError unless reference.callable?
      reference
    end
    
    def remove(reference)
      @exposed_id_table.delete(reference.exposed_id)
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
    
    def create(new_exposed_id)
      new_reference = RemoteReference.new(@connection, new_exposed_id)
      @exposed_id_table[new_exposed_id] = new_reference
      @transaction << new_reference if @transaction
      new_reference
    end
    
    def find(exposed_id)
      reference = @exposed_id_table[exposed_id]
      return if reference && reference.stale?
      reference
    end
    
    def each
      @exposed_id_table.values.each do |reference|
        yield(reference) unless reference.stale?
      end
    end
    
  end
end
