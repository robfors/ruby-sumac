module Sumac
  class Message
    class Object
      module Dispatch
      
        def self.from_json_structure(connection, json_structure)
          raise unless json_structure.is_a?(::Hash) && json_structure['message_type'] == 'object'
          case json_structure['object_type']
          when 'null'
            Null.from_json_structure(connection, json_structure)
          when 'boolean'
            Boolean.from_json_structure(connection, json_structure)
          when 'integer'
            Integer.from_json_structure(connection, json_structure)
          when 'float'
            Float.from_json_structure(connection, json_structure)
          when 'string'
            String.from_json_structure(connection, json_structure)
          when 'array'
            Array.from_json_structure(connection, json_structure)
          when 'hash_table'
            HashTable.from_json_structure(connection, json_structure)
          when 'exposed'
             Exposed.from_json_structure(connection, json_structure)
          else
            raise
          end
        end
        
        def self.from_native_object(connection, native_object)
          case
          when native_object.is_a?(ExposedObject) || native_object.is_a?(RemoteObject)
            Exposed.from_native_object(connection, native_object)
          when native_object == nil
            Null.from_native_object(connection, native_object)
          when native_object == true || native_object == false
            Boolean.from_native_object(connection, native_object)
          when native_object.is_a?(::Integer)
            Integer.from_native_object(connection, native_object)
          when native_object.is_a?(::Float)
            Float.from_native_object(connection, native_object)
          when native_object.is_a?(::String)
            String.from_native_object(connection, native_object)
          when native_object.is_a?(::Array)
            Array.from_native_object(connection, native_object)
          when native_object.is_a?(::Hash)
            HashTable.from_native_object(connection, native_object)
          else
            raise
          end
        end
        
      end
    end
  end
end
