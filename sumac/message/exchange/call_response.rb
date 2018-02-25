module Sumac
  module Message
    module Exchange
      class CallResponse < Exchange
      
        def initialize(connection)
          super
          @return_value = nil
        end
        
        def parse_json_structure(json_structure)
          raise unless json_structure.is_a?(Hash) &&
            json_structure['message_type'] == 'exchange' &&
            json_structure['exchange_type'] == 'call_response'
          raise unless json_structure['id'].is_a?(Integer)
          @id = json_structure['id']
          @return_value = Object::Dispatch.from_json_structure(@connection, json_structure['return_value'])
        end
        
        def to_json_structure
          raise unless setup?
          {
            'message_type' => 'exchange',
            'exchange_type' => 'call_response',
            'id' => @id,
            'return_value' => @return_value.to_json_structure
          }
        end
        
        def return_value
          raise unless setup?
          @return_value.to_native_object
        end
        
        def return_value=(new_return_value)
          @return_value = Object::Dispatch.from_native_object(@connection, new_return_value)
        end
        
        def invert_orgin
          raise unless setup?
          @return_value.invert_orgin if @return_value.respond_to?(:invert_orgin)
          nil
        end
        
        private
        
        def setup?
          super && @return_value != nil
        end
        
      end
    end
  end
end
