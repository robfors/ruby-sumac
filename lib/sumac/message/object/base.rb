class Sumac
  class Message
    class Object
      class Base < Object
      
        def self.from_json_structure(connection, json_structure)
          object = new(connection)
          object.parse_json_structure(json_structure)
          object
        end
        
        def self.from_native_object(connection, native_object)
          object = new(connection)
          object.parse_native_object(native_object)
          object
        end
        
      end
    end
  end
end
