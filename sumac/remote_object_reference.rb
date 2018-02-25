module Sumac
  class RemoteObjectReference < ObjectReference
    
    
    attr_reader :remote_object_wrapper
    
    
    def initialize(connection, exposed_id)
      @connection = connection
      @exposed_id = exposed_id
      @remote_object_wrapper = RemoteObjectWrapper.new(self)
    end
    
    
    def call(method_name, arguments)
      arguments.map! { |argument| native_to_reference(argument) }
      response = OutboundRequest.send(@connection, self, method_name, arguments)
      return reference_to_native(response)
    end
    
    
  end
end
