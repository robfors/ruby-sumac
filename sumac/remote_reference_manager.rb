module Sumac
  class RemoteReferenceManager
    include Celluloid
    
    
    def initialize(connection)
      @connection = connection
      @exposed_id_table = {}
    end
    
    
    def retrieve_or_create(exposed_id)
      return retrieve(exposed_id) || create(exposed_id)
    end
    
    
    def retrieve(exposed_id)
      reference = @exposed_id_table[exposed_id]
      raise 'object has been forgotten' unless reference #make better exception
      return reference
    end
    
    
    def create(new_exposed_id)
      new_reference = RemoteObjectReference.new(@connection, new_exposed_id)
      @exposed_id_table[new_reference.exposed_id] = new_reference
      return new_reference
    end
    
    
  end
end
