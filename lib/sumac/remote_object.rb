class Sumac
  class RemoteObject < Object
  
    def initialize(connection, remote_reference)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      raise unless remote_reference.is_a?(RemoteReference)
      @remote_reference = remote_reference
    end
    
    def method_missing(method_name, *arguments, &block)  # blocks not working yet
      raise StaleObjectError unless @remote_reference.callable?
      begin
        arguments << block.to_lambda if block_given?
        call = OutboundCall.new(connection, self, method_name.to_s, arguments)
        return_value = call.run
      rescue ClosedError
        raise StaleObjectError
      end
      return_value
    ensure
      @connection.mutex.unlock if @connection.mutex.owned?
    end
    
    def __remote_reference__
      @remote_reference
    end
    
    def forget
      @connection.mutex.synchronize { @remote_reference.local_forget_request }
      nil
    end
    
    def inspect
      "#<Sumac::RemoteObject:#{"0x00%x" % (object_id << 1)}>"
    end
    
  end
end
