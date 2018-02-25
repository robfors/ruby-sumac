module Sumac
  class CallProcessor
    include Emittable
    
    def initialize(orchestrator)
      raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
      @orchestrator = orchestrator
      @active_threads = []
    end
    
    def receive(exchange)
      raise MessageError unless exchange.is_a?(Message::Exchange::CallRequest)
      raise MessageError if @orchestrator.handshake.active? || @orchestrator.shutdown.active?
      raise MessageError unless exchange.exposed_object.is_a?(ExposedObject)
      @active_threads << Thread.new { async_process(exchange) }
      nil
    end
    
    def any_calls_processing?
      @active_threads.any?
    end
    
    #def kill_all
    #  @active_threads.each(&:kill)
    #end
    
    private
    
    def async_process(request)
      if request.exposed_object.class.__exposed_methods__.include?(request.method_name)
        return_value = request.exposed_object.__send__(request.method_name, *request.arguments)
      else
        raise 'no method'
      end
      @orchestrator.mutex.synchronize do
        response = Message::Exchange::CallResponse.new(@orchestrator)
        response.id = request.id
        response.return_value = return_value
        begin
          @orchestrator.transmitter.transmit(response)
        rescue Closed
          #ignore
        end
        @active_threads.delete(Thread.current)
        trigger(:exchange_processed)
      end
      nil
    end
    
  end
end
