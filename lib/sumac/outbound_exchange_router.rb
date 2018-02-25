module Sumac
  class OutboundExchangeRouter
  
    def initialize(connection, socket)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @socket = socket
      @semaphore = Mutex.new
    end
    
    def submit(exchange)
      raise unless exchange.is_a?(Exchange)
      @semaphore.synchronize do
        if exchange.is_a?(Exchange::Request)
          @connection.outbound_request_manager.submit(exchange)
        end
        message = exchange.to_message
        message.invert_orgin
        @socket.puts(message.to_json) #fix space issue
      end
      nil
    end
    
  end
end
