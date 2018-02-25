class Sumac
  class Message
    class Object
      class Null < Base
      
        def initialize(connection)
          super
          @setup = false
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(::Hash) &&
            json_structure['message_type'] == 'object' &&
            json_structure['object_type'] == 'null'
          @setup = true
          nil
        end
        
        def parse_native_object(native_object)
          raise MessageError unless native_object == nil
          @setup = true
          nil
        end
        
        def to_json_structure
          raise MessageError unless setup?
          {'message_type' => 'object', 'object_type' => 'null'}
        end
        
        def to_native_object
          raise MessageError unless setup?
          nil
        end
        
        private
        
        def setup?
          @setup
        end
        
      end
    end
  end
end
