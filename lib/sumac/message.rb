class Sumac
  class Message
  
    def self.from_json(connection, json)
      json_structure = JSON.parse(json)
      from_json_structure(connection, json_structure)
    end
    
    def initialize(connection)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
    end
    
    def to_json
      to_json_structure.to_json
    end
    
  end
end
