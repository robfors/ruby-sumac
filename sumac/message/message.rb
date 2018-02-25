module Sumac
  module Message
    class Message
    
      def self.from_json_structure(connection, json_structure)
        new_message = new(connection)
        new_message.parse_json_structure(json_structure)
        new_message
      end
      
      def initialize(connection)
        raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
        @connection = connection
      end
      
      def to_json
        to_json_structure.to_json
      end
      
    end
  end
end
