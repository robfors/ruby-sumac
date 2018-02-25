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
          else
            raise MessageError
          end
        object = object_class.from_json_structure(connection, json_structure)
        object
      end
      
      def self.from_native_object(connection, native_object)
        object_class = 
          case native_object
          when ExposedObject, RemoteObject
            Exposed
          when NilClass
            Null
          when TrueClass, FalseClass
            Boolean
          when *Exception.map.transpose[1]
            Exception
          when ::Exception
            NativeException
          when ::Integer
            Integer
          when ::Float
            Float
          when ::String
            String
          when ::Array
            Array
          when ::Hash
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
