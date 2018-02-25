module Sumac
  class RemoteObject < Object
  
    def initialize(connection, remote_reference)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      raise unless remote_reference.is_a?(Reference::Remote)
      @remote_reference = remote_reference
    end
    
    def method_missing(method_name, *arguments, &block)  # blocks not working yet
      request = Exchange::Request::Call.new(@connection)
      request.exposed_object = self
      request.method_name = method_name.to_s
      request.arguments = arguments
      response = request.send
      response.return_value
    end
    
    def __remote_reference__
      @remote_reference
    end
    
  end
end
