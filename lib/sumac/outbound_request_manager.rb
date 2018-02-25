module Sumac
  class OutboundRequestManager
  
    def initialize(connection)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @pending_requests = {}
      @id_allocator = IDAllocator.new
      @semaphore = Mutex.new
    end
    
    def submit(exchange)
      @semaphore.synchronize do
        case
        when exchange.is_a?(Exchange::Request)
          request_id = @id_allocator.allocate
          exchange.id = request_id
          @pending_requests[request_id] = exchange
        when exchange.is_a?(Exchange::Response)
          request = @pending_requests[exchange.id]
          request.submit_response(exchange)
          @pending_requests.delete(exchange.id)
          @id_allocator.free(exchange.id)
        else
          raise
        end
        nil
      end
    end
    
  end
end
