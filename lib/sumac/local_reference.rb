class Sumac
  class LocalReference < Reference
  
    attr_reader :exposed_object
    
    def initialize(connection, exposed_id, exposed_object)
      super(connection, exposed_id)
      @exposed_object = exposed_object
    end
    
    def quietly_forget
      @connection.local_references.remove(self)
      super
    end
    
  end
end
