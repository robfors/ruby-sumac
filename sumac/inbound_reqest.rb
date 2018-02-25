module Sumac
  class InboundRequest < MessageHelper
    include Celluloid
    
    def initialize(connection, message)
      @connection = connection
      @message = message
      @processed = false
    end
    
    def inbound_id_adjustment?
      true
    end
    
    def process
      raise 'Already processed' if @processed
      hash = JSON.parse(@message)
      @sequence_number = hash['sequence_number']
      @object = LocalReachableObject.new(@connection, hash['exposed_id']) #capture non existant local object error
      @method_name = hash['method_name']
      @arguments = hash['arguments'].map { |argument| prase(argument) }
      return_value = @object.call(@method_name, @arguments)
      response = OutboundResponse.new(@connection, self, return_value)
      @connection.inbound_request_manager.submit_response(response)
      @processed = true
      nil
    end
    
  end
end
