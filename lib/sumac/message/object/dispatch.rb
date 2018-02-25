module Sumac
  class Message
    class Object
      module Dispatch
      
        def self.from_json_structure(orchestrator, json_structure)
          raise MessageError unless json_structure.is_a?(::Hash) && json_structure['message_type'] == 'object'
          case json_structure['object_type']
          when 'null'
            Null.from_json_structure(orchestrator, json_structure)
          when 'boolean'
            Boolean.from_json_structure(orchestrator, json_structure)
          when 'exception'
            Exception.from_json_structure(orchestrator, json_structure)
          when 'native_exception'
            NativeException.from_json_structure(orchestrator, json_structure)
          when 'integer'
            Integer.from_json_structure(orchestrator, json_structure)
          when 'float'
            Float.from_json_structure(orchestrator, json_structure)
          when 'string'
            String.from_json_structure(orchestrator, json_structure)
          when 'array'
            Array.from_json_structure(orchestrator, json_structure)
          when 'hash_table'
            HashTable.from_json_structure(orchestrator, json_structure)
          when 'exposed'
             Exposed.from_json_structure(orchestrator, json_structure)
          else
            raise MessageError
          end
        end
        
        def self.from_native_object(orchestrator, native_object)
          case
          when native_object.is_a?(ExposedObject) || native_object.is_a?(RemoteObject)
            Exposed.from_native_object(orchestrator, native_object)
          when native_object == nil
            Null.from_native_object(orchestrator, native_object)
          when native_object == true || native_object == false
            Boolean.from_native_object(orchestrator, native_object)
          when Exception.map.rassoc(native_object.class) != nil
            Exception.from_native_object(orchestrator, native_object)
          when native_object.kind_of?(StandardError)
            NativeException.from_native_object(orchestrator, native_object)
          when native_object.is_a?(::Integer)
            Integer.from_native_object(orchestrator, native_object)
          when native_object.is_a?(::Float)
            Float.from_native_object(orchestrator, native_object)
          when native_object.is_a?(::String)
            String.from_native_object(orchestrator, native_object)
          when native_object.is_a?(::Array)
            Array.from_native_object(orchestrator, native_object)
          when native_object.is_a?(::Hash)
            HashTable.from_native_object(orchestrator, native_object)
          else
            raise UnexposableError
          end
        end
        
      end
    end
  end
end
