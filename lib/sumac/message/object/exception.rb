class Sumac
  class Message
    class Object
      class Exception < Base
      
        def self.map
          @map ||=
            [
              ['no_method_exception', NoMethodError],
              ['argument_exception', ArgumentError],
              ['stale_object_exception', StaleObjectError],
              ['unexposable_object_exception', UnexposableObjectError]
            ]
        end
        
        def initialize(connection)
          super
          @type = nil
          @message = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(::Hash) &&
            json_structure['message_type'] == 'object' &&
            json_structure['object_type'] == 'exception'
          raise MessageError if self.class.map.assoc(json_structure['type']) == nil
          @type = json_structure['type']
          if json_structure['message']
            raise MessageError unless json_structure['message'].is_a?(::String)
            @message = json_structure['message']
          end
          nil
        end
        
        def parse_native_object(native_object)
          raise MessageError if self.class.map.rassoc(native_object.class) == nil
          @type = self.class.map.rassoc(native_object.class)[0]
          @message = native_object.message
          nil
        end
        
        def to_json_structure
          raise MessageError unless setup?
          {
            'message_type' => 'object',
            'object_type' => 'exception',
            'type' => @type,
            'message' => @message
          }
        end
        
        def to_native_object
          raise MessageError unless setup?
          self.class.map.assoc(@type)[1].new(@message)
        end
        
        private
        
        def setup?
          @type != nil
        end
        
      end
    end
  end
end
