module Sumac
  class Message
    class Object < Message
    
      def self.from_native_object(orchestrator, native_object)
        new_message = new(orchestrator)
        new_message.parse_native_object(native_object)
        new_message
      end
      
    end
  end
end
