module Sumac
  class Handshake
    
    def initialize(connection)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @sent = false
      @waiter = Waiter.new
      @mutex = Mutex.new
      @resource = ConditionVariable.new
      @complete = false
    end
    
    def start
      raise if @sent
      @sent = true
      compatibility_exchange = Exchange::CompatibilityHandshake.new(@connection)
      compatibility_exchange.protocol_version = 1
      compatibility_exchange.send
      remote_compatibility_exchange = @waiter.wait
      raise unless remote_compatibility_exchange.is_a?(Exchange::CompatibilityHandshake)
      raise unless remote_compatibility_exchange.protocol_version == 1
      # know compatible
      entry_exchange = Exchange::EntryHandshake.new(@connection)
      entry_exchange.entry_object = @connection.local_entry
      entry_exchange.send
      remote_entry_exchange = @waiter.wait
      raise unless remote_entry_exchange.is_a?(Exchange::EntryHandshake)
      @connection.remote_entry = remote_entry_exchange.entry_object
      complete
    end
    
    def complete?
      @complete
    end
    
    def submit_remote_exchange(exchange)
      @waiter.resume(exchange)
    end
    
    def wait_until_complete
      @mutex.synchronize do
        @resource.wait(@mutex) unless complete?
      end
    end
    
    private
    
    def complete
      @resource.broadcast
      @complete = true
    end
    
  end
end
