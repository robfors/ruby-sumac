module Sumac
  module Request
    class OutboundCall
      include Translater
      
      
      def self.process(connection, remote_object_reference, method_name, arguments)
        request = new(connection)
        return_value = request.process(remote_object_reference, method_name, arguments)
        return return_value
      end
      
      
      def initialize(connection)
        raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
        @connection = connection
      end
      
      
      def process(remote_object_reference, method_name, arguments)
        unless remote_object_reference.is_a?(ObjectReference::Remote)
          raise "argument 'remote_object_reference' must be a ObjectReference::Remote"
        end
        raise "argument 'method_name' must be a String" unless method_name.is_a?(String)
        raise "argument 'arguments' must be an Array" unless arguments.is_a?(Array)
        
        request_message = Message.new
        request_message['type'] = 'call'
        request_message['exposed_id'] = reference_to_message(remote_object_reference)
        request_message['method_name'] = method_name
        request_message['arguments'] = arguments.map { |argument| reference_to_message(argument) }
        
        response_message = @connection.request_manager.submit_outbound_message(request_message)
        
        return_value = message_to_reference(response_message['return_value'])
        return return_value
      end
      
      
    end
  end
end
