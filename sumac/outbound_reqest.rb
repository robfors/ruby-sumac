module Sumac
  class OutboundRequest
    include MessageHelper
    
    
    def self.send(connection, remote_object_reference, method_name, arguments)
      request = new(connection, remote_object_reference, method_name, arguments)
      @connection.outbound_request_manager.submit(self)
      response_message = waiter.wait
      response = message_to_reference(response_message.hash['value'])
      return response
    end
    
    
    def initialize(connection, remote_object_reference, method_name, arguments)
      raise "Argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      unless remote_object_reference.is_a?(RemoteObjectReference)
        raise "Argument 'remote_object_reference' must be a RemoteObjectReference"
      end
      @remote_object_reference = remote_object_reference
      raise "Argument 'method_name' must be a String" unless method_name.is_a?(String)
      @method_name = method_name
      raise "Argument 'arguments' must be an Array" unless arguments.is_a?(Array)
      @arguments = arguments
      @sequence_number = nil
      @waiter = Waiter.new
    end
    
    
    def sequence_number=(new_sequence_number)
      @sequence_number = new_sequence_number
    end
    
    
    def message
      raise 'sequence_number not set' unless @sequence_number
      hash = {'type' => 'request'}
      hash['exposed_id'] = @remote_reachable_object.exposed_id
      hash['sequence_number'] = @sequence_number
      hash['arguments'] = @arguments.map { |argument| reference_to_message(argument) }
      Message.build(hash)
    end
    
    
    def submit_response(response_message)
      @waiter.resume(response_message)
    end
    
    
  end
end
