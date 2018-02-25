module Sumac
  class Message
    class Object
      class NativeException < Object
      
        def initialize(orchestrator)
          super
          @type = nil
          @message = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(::Hash) &&
            json_structure['message_type'] == 'object' &&
            json_structure['object_type'] == 'native_exception'
          raise MessageError unless json_structure['type'].is_a?(::String)
          @type = json_structure['type']
          raise MessageError unless json_structure['message'].is_a?(::String)
          @message = json_structure['message']
          nil
        end
        
        def parse_native_object(native_object)
          raise MessageError unless native_object.kind_of?(StandardError)
          @type = native_object.class.to_s
          @message = native_object.message
          nil
        end
        
        def to_json_structure
          raise MessageError unless setup?
          {
            'message_type' => 'object',
            'object_type' => 'native_exception',
            'type' => @type,
            'message' => @message
          }
        end
        
        def to_native_object
          raise MessageError unless setup?
          Sumac::NativeException.new(@type, @message)
        end
        
        private
        
        def setup?
          @type != nil && @message != nil
        end
        
      end
    end
  end
end
