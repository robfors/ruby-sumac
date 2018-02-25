module Sumac
  class OutboundExchangeSender
  
    def initialize(connection, socket)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @socket = socket
    end
    
    def send(exchange)
      raise unless exchange.is_a?(Exchange)
      message = exchange.to_message
      message.invert_orgin
      @socket.puts(message.to_json)
      nil
    end
    
  end
end
