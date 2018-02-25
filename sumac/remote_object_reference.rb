module Sumac
  class RemoteObjectReference < ObjectReference
  
    def initialize(connection, id)
      @connection = connection
      @id = id
    end
  
    def call(method_name, arguments)
      arguments.map! { |argument| native_to_reference(argument) }
      return_value = RemoteRequest.send(@connection, self, method_name, arguments)
      return reference_to_native(return_value)
    end
    
  end
end
