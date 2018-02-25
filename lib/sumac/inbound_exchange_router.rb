module Sumac
  class InboundExchangeRouter
  
    def initialize(connection, socket)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @inbound_exchange_receiver = InboundExchangeReceiver.new(connection, socket)
      @thread = nil
    end
    
    def run
      @thread = Thread.new do
        loop do
          exchange = @inbound_exchange_receiver.get_next_exchange
          process(exchange)
        end
      end
      nil
    end
    
    private
    
    def process(exchange)
      if exchange.is_a?(Exchange::Response)
        @connection.outbound_request_manager.submit(exchange)
      else
        @connection.inbound_exchange_manager.submit(exchange)
      end
      nil
    end
    
  end
end
