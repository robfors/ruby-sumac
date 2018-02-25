module Sumac
  class Message
    class Exchange
      class EntryHandshake < Exchange
      
        def initialize(connection)
          super
          @entry_object = nil
        end
        
        def parse_json_structure(json_structure)
          raise unless json_structure.is_a?(Hash) &&
            json_structure['message_type'] == 'exchange' &&
            json_structure['exchange_type'] == 'entry_handshake'
          @entry_object = Object::Dispatch.from_json_structure(@connection, json_structure['entry_object'])
        end
        
        def to_json_structure
          raise unless setup?
          {
            'message_type' => 'exchange',
            'exchange_type' => 'entry_handshake',
            'entry_object' => @entry_object.to_json_structure
          }
        end
        
        def entry_object
          raise unless setup?
          @entry_object.to_native_object
        end
        
        def entry_object=(new_entry_object)
          @entry_object = Object::Dispatch.from_native_object(@connection, new_entry_object)
        end
        
        def invert_orgin
          raise unless setup?
          @entry_object.invert_orgin if @entry_object.respond_to?(:invert_orgin)
          nil
        end
        
        private
        
        def setup?
          @entry_object != nil
        end
        
      end
    end
  end
end
