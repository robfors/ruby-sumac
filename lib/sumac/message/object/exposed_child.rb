class Sumac
  class Message
    class Object
      class ExposedChild < Base
      
        def initialize(connection)
          super
          @parent = nil
          @key = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(::Hash) &&
            json_structure['message_type'] == 'object' &&
            json_structure['object_type'] == 'exposed_child'
          @parent = Exposed.from_json_structure(@connection, json_structure['parent'])
          key = json_structure['key']
          raise MessageError unless key.is_a?(::String) || key.is_a?(::Float) || key.is_a?(::Integer)
          @key = key
          nil
        end
        
        def parse_native_object(native_object)
          unless native_object.is_a?(RemoteObjectChild) ||
                (native_object.respond_to?(:__sumac_exposed_object__) && native_object.respond_to?(:__parent__))
            raise MessageError
          end
          begin
            native_parent = native_object.__parent__
          rescue
            raise MessageError
          end
          @parent = Exposed.from_native_object(@connection, native_parent)
          begin
            key = native_object.__key__
          rescue
            raise MessageError
          end
          raise unless key.is_a?(::String) || key.is_a?(::Float) || key.is_a?(::Integer)
          @key = key
          nil
        end
        
        def to_json_structure
          raise MessageError unless setup?
          {
            'message_type' => 'object',
            'object_type' => 'exposed_child',
            'parent' => @parent.to_json_structure,
            'key' => @key
          }
        end
        
        def to_native_object
          raise MessageError unless setup?
          native_parent = @parent.to_native_object
          case native_parent
          when ExposedObject
            begin
              native_child = native_parent.__child__(@key)
            rescue
              raise MessageError
            end
            raise unless native_child.is_a?(ExposedObjectChild)
          when RemoteObject
            native_child = RemoteObjectChild.new(@connection, native_parent, @key)
          end
          native_child
        end
        
        def invert_orgin
          raise MessageError unless setup?
          @parent.invert_orgin
          nil
        end
        
        private
        
        def setup?
          @parent != nil && @key != nil
        end
        
      end
    end
  end
end
