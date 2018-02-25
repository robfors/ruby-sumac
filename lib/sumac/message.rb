module Sumac
  class Message
  
    def self.from_json_structure(orchestrator, json_structure)
      new_message = new(orchestrator)
      new_message.parse_json_structure(json_structure)
      new_message
    end
    
    def initialize(orchestrator)
      raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
      @orchestrator = orchestrator
    end
    
    def to_json
      to_json_structure.to_json
    end
    
  end
end
