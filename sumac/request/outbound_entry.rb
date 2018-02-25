module Sumac
  module Request
    class OutboundEntry
      include Translater
      
      
      def self.process(connection)
        request = new(connection)
        return_value = request.process
        return return_value
      end
      
      
      def initialize(connection)
        raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
        @connection = connection
      end
      
      
      def process
        request_message = Message.new
        request_message['type'] = 'entry'
        
        response_message = @connection.request_manager.submit_outbound_message(request_message)
        
        return_value = message_to_reference(response_message['entry_object'])
        return return_value
      end
      
      
    end
  end
end
