module Sumac
  class OutboundExchangeRouter
  
    def initialize(connection, socket)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @outbound_exchange_sender = OutboundExchangeSender.new(connection, socket)
      @semaphore = Mutex.new
    end
    
    def submit(exchange)
      raise unless exchange.is_a?(Exchange)
      @semaphore.synchronize do
        if exchange.is_a?(Exchange::Request)
          @connection.outbound_request_manager.submit(exchange)
        end
        @outbound_exchange_sender.send(exchange)
      end
      nil
    end
    
  end
end
