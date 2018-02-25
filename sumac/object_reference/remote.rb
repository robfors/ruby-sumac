module Sumac
  module ObjectReference
    class Remote
      include Translater
      
      
      attr_reader :exposed_id, :remote_object_wrapper
      
      
      def initialize(connection, exposed_id)
        @connection = connection
        @exposed_id = exposed_id
        @remote_object_wrapper = RemoteObjectWrapper.new(self)
      end
      
      
      def call(method_name, arguments)
        arguments.map! { |argument| native_to_reference(argument) }
        response = Request::OutboundCall.process(@connection, self, method_name, arguments)
        return reference_to_native(response)
      end
      
      
    end
  end
end
