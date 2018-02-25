module Sumac
  class InboundExchangeRouter
  
    def initialize(connection, socket)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @socket = socket
      @thread = nil
    end
    
    def get_next_exchange
      begin
        json = @socket.gets #fix space isssue
      rescue
        raise 'network error'
      end
      raise 'network error' unless json
      
      message = Message::Exchange::Dispatch.from_json(@connection, json)  
      
      #begin
      #  
      #rescue
      #  raise 'message invalid'
      #end
      
      #binding.pry
      exchange = Exchange::Dispatch.from_message(@connection, message)   
      
      #begin
      #  
      #rescue
      #  raise 'exchange invalid'
      #end
      
      exchange
    end
    
    def run
      @thread = Thread.new do
        loop do
          exchange = get_next_exchange
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
