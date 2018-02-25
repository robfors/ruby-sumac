module Sumac
  module Request
    class InboundEntry
      include Translater
      
      
      def self.process(connection, request_message)
        request = new(connection)
        response_message = request.process
        return response_message
      end
      
      
      def initialize(connection)
        raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
        @connection = connection
      end
      
      
      def process
        local_entry = ObjectReference::LocalEntry.retrieve(@connection)
        
        response_message = Message.new
        response_message['entry_object'] = reference_to_message(local_entry)
        return response_message
      end
      
      
    end
  end
end
