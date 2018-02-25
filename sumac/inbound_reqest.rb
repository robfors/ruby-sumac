module Sumac
  class InboundRequest
    include MessageHelper
    include Celluloid
    
    
    def initialize(connection, message)
      @connection = connection
      @message = message
    end
    
    
    def sequence_number
      @message.sequence_number
    end
    
    
    def process
      hash = @message.hash
      object = LocalObjectReference.new(@connection, hash['exposed_id']) #capture non existant local object error
      method_name = hash['method_name']
      arguments = hash['arguments'].map { |argument| message_to_reference(argument) }
      
      return_value = object.call(method_name, arguments)
      
      response_hash = {'type' => 'response'}
      response_hash['sequence_number'] = sequence_number
      response_hash['value'] = reference_to_message(return_value)
      message = Message.build(response_hash)
      @connection.inbound_request_manager.submit_response(message)
      nil
    end
    
    
  end
end
