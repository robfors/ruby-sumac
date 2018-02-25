class Sumac
  class RemoteReference < Reference
  
    attr_reader :remote_object
    
    def initialize(connection, exposed_id)
      super(connection, exposed_id)
      @remote_object = RemoteObject.new(@connection, self)
    end
    
    def quietly_forget
      @connection.remote_references.remove(self)
      super
    end
    
  end
end
