module Sumac
  class Network
  
    def initialize(orchestrator, socket)
      raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
      @orchestrator = orchestrator
      @socket = socket
    end
    
    def transmit(json)
      raise Closed if @orchestrator.closed?
      begin
        @socket.puts(json)
      rescue
        network_error unless @orchestrator.closed?
        raise Closed
      end
      nil
    end
    
    def receive
      raise Closed if @orchestrator.closed?
      begin
        json = @socket.gets
        raise Closed unless json
      rescue
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
      @socket.close rescue nil
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
