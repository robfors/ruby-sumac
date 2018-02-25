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
      raise MessageError if @active_threads.length > 10
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
      @orchestrator.mutex.lock
      response = Message::Exchange::CallResponse.new(@orchestrator)
      response.id = request.id
      if request.exposed_object.__exposed_methods__.include?(request.method_name)
        #binding.pry
        begin
          @orchestrator.mutex.unlock
          return_value = request.exposed_object.__send__(request.method_name, *request.arguments)
          @orchestrator.mutex.lock
        rescue StandardError => e
          @orchestrator.mutex.lock
          response.exception = e
        else
          begin
            response.return_value = return_value
          rescue UnexposableError
            response.exception = UnexposableError.new
          end
        end
      else
        response.exception = NoMethodError.new
      end
      begin
        @orchestrator.transmitter.transmit(response)
      rescue Closed
        #ignore
      end
      @active_threads.delete(Thread.current)
      trigger(:exchange_processed)
      @orchestrator.mutex.unlock
      nil
    end
    
  end
end
