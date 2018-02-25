module Sumac
  class CallDispatcher
    include Emittable
    
    def initialize(orchestrator)
      raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
      @orchestrator = orchestrator
      @pending_requests = {}
      @id_allocator = IDAllocator.new
    end
    
    #def cancel_all
    #  @pending_requests.each {|waiter| waiter.resume(nil) }
    #  nil
    #end
    
    def any_calls_pending?
      @pending_requests.any?
    end
    
    def make_call(exposed_object, method_name, arguments)
      #binding.pry
      raise if @orchestrator.handshake.active?
      raise Closed if @orchestrator.shutdown.initiated?
      id = @id_allocator.allocate
      request = Message::Exchange::CallRequest.new(@orchestrator)
      request.id = id
      raise unless exposed_object.is_a?(RemoteObject)
      request.exposed_object = exposed_object
      request.method_name = method_name
      request.arguments = arguments
      @orchestrator.transmitter.transmit(request)
      waiter = Waiter.new
      @pending_requests[id] = waiter
      @orchestrator.mutex.unlock
      response = waiter.wait
      @orchestrator.mutex.lock
      @pending_requests.delete(id)
      @id_allocator.free(id)
      trigger(:request_completed)
      #raise ConectionClosed if response == nil
      raise response.exception if response.exception
      response.return_value
    ensure
      @id_allocator.free(id) if id && @id_allocator.allocated?(id)
    end
    
    def receive(exchange)
      raise MessageError unless exchange.is_a?(Message::Exchange::CallResponse)
      waiter = @pending_requests[exchange.id]
      raise MessageError unless waiter
      waiter.resume(exchange)
      nil
    end
    
  end
end
