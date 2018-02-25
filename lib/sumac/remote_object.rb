module Sumac
  class RemoteObject < Object
  
    def initialize(orchestrator, remote_reference)
      raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
      @orchestrator = orchestrator
      raise unless remote_reference.is_a?(Reference::Remote)
      @remote_reference = remote_reference
    end
    
    def method_missing(method_name, *arguments, &block)  # blocks not working yet
      begin
        return_value = @orchestrator.call_dispatcher.make_call(self, method_name.to_s, arguments)
      rescue Closed
        raise StaleObject
      end
      return_value
    end
    
    def __remote_reference__
      @remote_reference
    end
    
  end
end
