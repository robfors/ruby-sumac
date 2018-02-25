module Sumac
  module Exchange
    class OutboundRequestManager
    
      def initialize(connection)
        raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
        @connection = connection
        @pending_requests = {}
        @id_allocator = IDAllocator.new
        @semaphore = Mutex.new
      end
      
      def send(request)
        raise unless request.kind_of?(Request::Request)
        request_id = @id_allocator.allocate
        request.id = request_id
        waiter = Waiter.new
        @semaphore.synchronize { @pending_requests[request_id] = waiter }
        @connection.exchange_router.send(request)
        response = waiter.wait
        @semaphore.synchronize { @pending_requests.delete(request_id) }
        @id_allocator.free(request_id)
        response
      end
      
      def submit_response(response)
        raise unless response.kind_of?(Response::Response)
        request_id = response.id
        @semaphore.synchronize { @pending_requests[request_id].resume(response) }
      end
      
    end
  end
end
