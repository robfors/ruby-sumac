module Sumac
  class Exchange
    class CallRequest < Request
    
      def initialize(connection)
        super
        @exposed_object = nil
        @method_name = nil
        @arguments = nil
        @waiter = nil
      end
      
      def parse_message(message)
        raise unless message.is_a?(Message::Exchange::CallRequest)
        raise unless message.id.is_a?(Integer)
        @id = message.id
        raise unless message.exposed_object.is_a?(ExposedObject) ||
          message.exposed_object.is_a?(RemoteObject)
        @exposed_object = message.exposed_object
        raise unless message.method_name.is_a?(String)
        @method_name = message.method_name
        raise unless message.arguments.is_a?(Array)
        @arguments = message.arguments
        nil
      end
      
      def exposed_object
        raise unless setup?
        @exposed_object
      end
      
      def exposed_object=(new_exposed_object)
        raise unless new_exposed_object.is_a?(ExposedObject) ||
          new_exposed_object.is_a?(RemoteObject)
        @exposed_object = new_exposed_object
      end
      
      def method_name
        raise unless setup?
        @method_name
      end
      
      def method_name=(new_method_name)
        raise unless new_method_name.is_a?(String)
        @method_name = new_method_name
      end
      
      def arguments
        raise unless setup?
        @arguments
      end
      
      def arguments=(new_arguments)
        raise unless new_arguments.is_a?(Array)
        @arguments = new_arguments
      end
      
      def to_message
        raise unless setup?
        message = Message::Exchange::CallRequest.new(@connection)
        message.id = @id
        message.exposed_object = @exposed_object
        message.method_name = @method_name
        message.arguments = @arguments
        message
      end
      
      def submit_response(response)
        raise unless response.is_a?(CallResponse)
        @waiter.resume(response)
        nil
      end
      
      def send
        raise unless @exposed_object.is_a?(RemoteObject)
        @waiter = Waiter.new
        @connection.outbound_exchange_router.submit(self)
        response = @waiter.wait
        response
      end
      
      def process
        raise unless setup?
        raise unless @exposed_object.is_a?(ExposedObject)
        return_value = @exposed_object.__send__(method_name, *@arguments)
        response = CallResponse.new(@connection)
        response.id = @id
        response.return_value = return_value
        @connection.outbound_exchange_router.submit(response)
        nil
      end
      
      private
      
      def setup?
        super && @exposed_object != nil && @method_name != nil && @arguments != nil
      end
      
    end
  end
end
