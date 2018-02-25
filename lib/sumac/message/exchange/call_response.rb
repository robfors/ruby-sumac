module Sumac
  class Message
    class Exchange
      class CallResponse < RequestResponse
      
        def initialize(orchestrator)
          super
          @return_value = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(Hash) &&
            json_structure['message_type'] == 'exchange' &&
            json_structure['exchange_type'] == 'call_response'
          raise MessageError unless json_structure['id'].is_a?(Integer)
          @id = json_structure['id']
          @return_value = Object::Dispatch.from_json_structure(@orchestrator, json_structure['return_value'])
          nil
        end
        
        def to_json_structure
          raise MessageError unless setup?
          {
            'message_type' => 'exchange',
            'exchange_type' => 'call_response',
            'id' => @id,
            'return_value' => @return_value.to_json_structure
          }
        end
        
        def return_value
          raise MessageError unless setup?
          @return_value.to_native_object
        end
        
        def return_value=(new_return_value)
          @return_value = Object::Dispatch.from_native_object(@orchestrator, new_return_value)
        end
        
        def invert_orgin
          raise MessageError unless setup?
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
