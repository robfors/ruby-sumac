module Sumac
  class InboundExchangeReceiver
  
    def initialize(connection, socket)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @socket = socket
    end
    
    def get_next_exchange
      json = get_next_json_string 
      raise 'network error' unless json
      message = parse_json(json)
      exchange = parse_message(message)
      exchange
    end
    
    
    private
    
    def get_next_json_string
      begin
        @socket.gets
      rescue
        raise 'network error'
      end
    end
    
    def parse_json(json)
      #begin
        message = Message::Exchange::Dispatch.from_json(@connection, json)
      #rescue
      #  raise 'message invalid'
      #end
      message
    end
    
    def parse_message(message)
      #begin
        exchange = Exchange::Dispatch.from_message(@connection, message)
      #rescue
      #  raise 'exchange invalid'
      #end
      exchange
    end
    
  end
end
