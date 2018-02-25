module Sumac
  class Exchange
  
    def self.from_message(connection, message)
      new_exchange = new(connection)
      new_exchange.parse_message(message)
      new_exchange
    end
    
    def initialize(connection)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
    end
    
    def to_json
      to_message.to_json
    end
    
  end
end
