module Sumac
  module ObjectReference
    class Local
      include Translater
      
      
      attr_reader :exposed_id, :exposed_object
      
      
      def initialize(connection, exposed_id, exposed_object)
        @connection = connection
        @exposed_id = exposed_id
        @exposed_object = exposed_object
      end
      
      
      def call(method_name, arguments)
        arguments.map! { |argument| reference_to_native(argument) }
        return_value = @exposed_object.__send__(method_name, *arguments)
        return native_to_reference(return_value)
      end
      
      
    end
  end
end
