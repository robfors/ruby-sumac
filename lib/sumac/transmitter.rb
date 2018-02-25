module Sumac
  class Transmitter
  
    def initialize(orchestrator)
      raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
      @orchestrator = orchestrator
    end
    
    def transmit(exchange)
      raise unless exchange.is_a?(Message::Exchange)
      exchange.invert_orgin
      json = exchange.to_json
      begin
        @orchestrator.messenger.send(json)
      rescue Adapter::Closed, Adapter::ConnectionError
        network_error unless @orchestrator.closed?
        raise Closed
      end
      nil
    end
    
    def network_error
      @orchestrator.close
      @orchestrator.connection.trigger(:network_error)
      nil
    end
    
  end
end
