class Sumac
  class Message
    class Object < Message
    
      def self.from_json_structure(connection, json_structure)
        raise MessageError unless json_structure.is_a?(::Hash) && json_structure['message_type'] == 'object'
        object_class = 
          case json_structure['object_type']
          when 'null'
            Null
          when 'boolean'
            Boolean
          when 'exception'
            Exception
          when 'native_exception'
            NativeException
          when 'integer'
            Integer
          when 'float'
            Float
          when 'string'
            String
          when 'array'
            Array
          when 'hash_table'
            HashTable
          when 'exposed'
            Exposed
          when 'exposed_child'
            ExposedChild
          else
            raise MessageError
          end
        object = object_class.from_json_structure(connection, json_structure)
        object
      end
      
      def self.from_native_object(connection, native_object)
        object_class = 
          case
          when native_object.is_a?(RemoteObject) || (native_object.respond_to?(:__sumac_exposed_object__) && native_object.respond_to?(:__native_id__))
            Exposed
          when native_object.is_a?(RemoteObjectChild) || (native_object.respond_to?(:__sumac_exposed_object__) && native_object.respond_to?(:__parent__))
            ExposedChild
          when native_object == nil
            Null
          when native_object == true || native_object == false
            Boolean
          when Exception.map.transpose[1].any? { |klass| native_object.is_a?(klass) }
            Exception
          when native_object.is_a?(::Exception)
            NativeException
          when native_object.is_a?(::Integer)
            Integer
          when native_object.is_a?(::Float)
            Float
          when native_object.is_a?(::String)
            String
          when native_object.is_a?(::Array)
            Array
          when native_object.is_a?(::Hash)
            HashTable
          else
            raise UnexposableObjectError
          end
        object = object_class.from_native_object(connection, native_object)
        object
      end
      
    end
  end
end
