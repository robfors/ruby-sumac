class Sumac
  class RemoteObjectChild < Object
  
    def initialize(connection, parent, key)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      raise unless parent.is_a?(RemoteObject)
      @parent = parent
      @key = key
    end
    
    def method_missing(method_name, *arguments, &block)  # blocks not working yet
      @connection.mutex.lock
      begin
        arguments << block.to_lambda if block_given?
        return_value = @connection.call_dispatcher.make_call(self, method_name.to_s, arguments)
      rescue ClosedError
        raise StaleObjectError
      end
      return_value
    ensure
      @connection.mutex.unlock if @connection.mutex.owned?
    end
    
    def __key__
      @key
    end
    
    def __parent__
      @parent
    end
    
    def inspect
      "#<Sumac::RemoteObjectChild:#{"0x00%x" % (object_id << 1)}>"
    end
    
  end
end
