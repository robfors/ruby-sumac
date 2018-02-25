class Sumac
  class RemoteReference < Reference
  
    attr_reader :remote_object
    
    def initialize(connection, exposed_id)
      super(connection, exposed_id)
      @remote_object = RemoteObject.new(@connection, self)
    end
    
    def remove
      @connection.remote_references.remove(self)
    end
    
  end
end
