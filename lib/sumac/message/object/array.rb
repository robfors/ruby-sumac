module Sumac
  class Message
    class Object
      class Array < Object
      
        def initialize(orchestrator)
          super
          @elements = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(::Hash) &&
            json_structure['message_type'] == 'object' &&
            json_structure['object_type'] == 'array'
          raise MessageError unless json_structure['elements'].is_a?(::Array)
          @elements = json_structure['elements'].map do |element|
            Dispatch.from_json_structure(@orchestrator, element)
          end
          nil
        end
        
        def parse_native_object(native_object)
          raise MessageError unless native_object.is_a?(::Array)
          @elements = native_object.map { |element| Dispatch.from_native_object(@orchestrator, element) }
          nil
        end
        
        def to_json_structure
          raise MessageError unless setup?
          {
            'message_type' => 'object',
            'object_type' => 'array',
            'elements' => @elements.map(&:to_json_structure)
          }
        end
        
        def to_native_object
          raise MessageError unless setup?
          @elements.map(&:to_native_object)
        end
        
        def invert_orgin
          raise MessageError unless setup?
          @elements.each { |element| element.invert_orgin if element.respond_to?(:invert_orgin) }
          nil
        end
        
        private
        
        def setup?
          @elements != nil
        end
        
      end
    end
  end
end
