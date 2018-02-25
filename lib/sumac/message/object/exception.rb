module Sumac
  class Message
    class Object
      class Exception < Object
      
        def self.map
          [
            ['no_method_error', NoMethodError],
            ['argument_error', ArgumentError],
            ['unexposable_error', UnexposableError]
          ]
        end
        
        def initialize(orchestrator)
          super
          @type = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(::Hash) &&
            json_structure['message_type'] == 'object' &&
            json_structure['object_type'] == 'exception'
          raise MessageError if self.class.map.assoc(json_structure['type']) == nil
          @type = json_structure['type']
          nil
        end
        
        def parse_native_object(native_object)
          raise MessageError if self.class.map.rassoc(native_object.class) == nil
          @type = self.class.map.rassoc(native_object.class)[0]
          nil
        end
        
        def to_json_structure
          raise MessageError unless setup?
          {'message_type' => 'object', 'object_type' => 'exception', 'type' => @type}
        end
        
        def to_native_object
          raise MessageError unless setup?
          self.class.map.assoc(@type)[1].new
        end
        
        private
        
        def setup?
          @type != nil
        end
        
      end
    end
  end
end
