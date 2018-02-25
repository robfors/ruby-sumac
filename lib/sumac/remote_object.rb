module Sumac
  class RemoteObject < Object
  
    def initialize(orchestrator, remote_reference)
      raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
      @orchestrator = orchestrator
      raise unless remote_reference.is_a?(Reference::Remote)
      @remote_reference = remote_reference
    end
    
    def method_missing(method_name, *arguments, &block)  # blocks not working yet
      @orchestrator.mutex.lock
      if @orchestrator.closed? || @remote_reference.forgeten?
        @orchestrator.mutex.unlock
        raise StaleObject
      end
      begin
        arguments << block.to_lambda if block_given?
        return_value = @orchestrator.call_dispatcher.make_call(self, method_name.to_s, arguments)
      rescue Closed
        @orchestrator.mutex.unlock
        raise StaleObject
      end
      @orchestrator.mutex.unlock
      return_value
    end
    
    def __remote_reference__
      @remote_reference
    end
    
    def forget
      @remote_reference.forget
      nil
    end
    
  end
end
