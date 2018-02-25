module Sumac
  class Message
    class Object
      class String < Object
      
        def initialize(orchestrator)
          super
          @value = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(::Hash) &&
            json_structure['message_type'] == 'object' &&
            json_structure['object_type'] == 'string'
          raise MessageError unless json_structure['value'].is_a?(::String)
          @value = json_structure['value']
          nil
        end
        
        def parse_native_object(native_object)
          raise MessageError unless native_object.is_a?(::String)
          @value = native_object
          nil
        end
        
        def to_json_structure
          raise MessageError unless setup?
          {'message_type' => 'object', 'object_type' => 'string', 'value' => @value}
        end
        
        def to_native_object
          raise MessageError unless setup?
          @value
        end
        
        private
        
        def setup?
          @value != nil
        end
        
      end
    end
  end
end
