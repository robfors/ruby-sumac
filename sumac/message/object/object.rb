module Sumac
  module Message
    module Object
      class Object < Message
      
        def self.from_native_object(connection, native_object)
          new_message = new(connection)
          new_message.parse_native_object(native_object)
          new_message
        end
        
      end
    end
  end
end
