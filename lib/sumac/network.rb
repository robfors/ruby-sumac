module Sumac
  class Network
  
    def initialize(orchestrator, messenger)
      raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
      @orchestrator = orchestrator
      @messenger = messenger
    end
    
    def transmit(json)
      raise Closed if @orchestrator.closed?
      begin
        @messenger.send(json)
      rescue Adapter::Closed, Adapter::ConnectionError
        network_error unless @orchestrator.closed?
        raise Closed
      end
      nil
    end
    
    def receive
      raise Closed if @orchestrator.closed?
      begin
        json = @messenger.receive
      rescue Adapter::Closed, Adapter::ConnectionError
        @orchestrator.mutex.synchronize do
          unless @orchestrator.closed?
            network_error
          end
        end
        raise Closed
      end
      json
    end
    
    def close
      #@messenger.close
      nil
    end
    
    private
    
    def network_error
      @orchestrator.close
      @orchestrator.connection.trigger(:network_error)
      nil
    end
    
  end
end
