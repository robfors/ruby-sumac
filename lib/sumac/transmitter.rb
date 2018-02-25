module Sumac
  class Transmitter
  
    def initialize(orchestrator)
      raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
      @orchestrator = orchestrator
    end
    
    def transmit(exchange)
      raise unless exchange.is_a?(Message::Exchange)
      exchange.invert_orgin
      @orchestrator.network.transmit(exchange.to_json)
      nil
    end
    
  end
end
