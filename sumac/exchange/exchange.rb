module Sumac
  module Exchange
    class Exchange
    
      def self.from_message(connection, message)
        new_exchange = new(connection)
        new_exchange.parse_message(message)
        new_exchange
      end
    
      def initialize(connection)
        raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
        @connection = connection
        @id = nil
      end
      
      def id
        raise unless setup?
        @id
      end
      
      def id=(new_id)
        raise unless new_id.is_a?(Integer)
        @id = new_id
      end
      
      def to_json
        to_message.to_json
      end
      
      private
      
      def setup?
        @id != nil
      end
      
    end
  end
end
