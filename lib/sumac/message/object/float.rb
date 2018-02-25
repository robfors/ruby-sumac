module Sumac
  class Message
    class Object
      class Float < Object
      
        def initialize(orchestrator)
          super
          @value = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(::Hash) &&
            json_structure['message_type'] == 'object' &&
            json_structure['object_type'] == 'float'
          raise MessageError unless json_structure['value'].is_a?(::Numeric)
          @value = json_structure['value'].to_f
          nil
        end
        
        def parse_native_object(native_object)
          raise MessageError unless native_object.is_a?(::Float)
          @value = native_object
          nil
        end
        
        def to_json_structure
          raise MessageError unless setup?
          {'message_type' => 'object', 'object_type' => 'float', 'value' => @value}
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
