module Sumac
  module Request
    class InboundCall
      include Translater
      
      
      def self.process(connection, request_message)
        request = new(connection)
        response_message = request.process(request_message)
        return response_message
      end
      
      
      def initialize(connection)
        raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
        @connection = connection
      end
      
      
      def process(request_message)
        local_object_reference = @connection.local_reference_manager.retrieve(request_message['exposed_id'].number) #capture non existant local object error
        method_name = request_message['method_name']
        arguments = request_message['arguments'].map { |argument| message_to_reference(argument) }
        
        return_value = local_object_reference.call(method_name, arguments)
        
        response_message = Message.new
        
        response_message['return_value'] = reference_to_message(return_value)
        return response_message
      end
      
      
    end
  end
end
