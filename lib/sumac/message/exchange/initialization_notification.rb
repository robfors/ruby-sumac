class Sumac
  class Message
    class Exchange
      class InitializationNotification < Notification
      
        def initialize(connection)
          super
          @entry = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(Hash) &&
            json_structure['message_type'] == 'exchange' &&
            json_structure['exchange_type'] == 'initialization_notification'
          @entry = Object::Dispatch.from_json_structure(@connection, json_structure['entry'])
          nil
        end
        
        def to_json_structure
          raise MessageError unless setup?
          {
            'message_type' => 'exchange',
            'exchange_type' => 'initialization_notification',
            'entry' => @entry.to_json_structure
          }
        end
        
        def entry
          raise MessageError unless setup?
          @entry.to_native_object
        end
        
        def entry=(new_entry_object)
          @entry = Object::Dispatch.from_native_object(@connection, new_entry_object)
        end
        
        def invert_orgin
          raise MessageError unless setup?
          @entry.invert_orgin if @entry.respond_to?(:invert_orgin)
          nil
        end
        
        private
        
        def setup?
          @entry != nil
        end
        
      end
    end
  end
end
