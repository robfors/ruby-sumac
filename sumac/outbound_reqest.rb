module Sumac
  class OutboundRequest < MessageHelper
    
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
      @response_waiter = Waiter.new
    end
    
    def sequence_number=(new_sequence_number)
      @sequence_number = new_sequence_number
    end
    
    def message
      raise 'sequence_number not set' unless @sequence_number
      hash = {'type' => 'request'}
      hash['exposed_id'] = @remote_reachable_object.id
      hash['sequence_number'] = @sequence_number
      hash['arguments'] = @arguments.map { |argument| object_to_message(argument) }
      hash.to_json
    end
    
    def send
      @connection.request_manager.submit(self)
      response = response_waiter.wait
      response.value
    end
    
    def response(returned_response)
      @response_waiter.resume(returned_response)
    end
    
  end
end
