class Sumac
  class Message
    class Exchange
      class Base < Exchange
      
        def self.from_json_structure(connection, json_structure)
          object = new(connection)
          object.parse_json_structure(json_structure)
          object
        end
        
      end
    end
  end
end
