module Sumac
  class RequestManager
    
    
    def initialize(connection)
      @connection = connection
      @pending_requests = []
      @id_allocator = IDAllocator.new
      @semaphore = Mutex.new
    end
    
    
    def submit_outbound_message(message)
      request_id = @id_allocator.allocate
      message['request_id'] = Message::ID.new(request_id, :local)
      waiter = Waiter.new
      @semaphore.synchronize do
        @pending_requests[request_id] = waiter
      end
      @connection.message_router.send(message)
      response = waiter.wait
      @semaphore.synchronize do
        @pending_requests.delete(request_id)
      end
      @id_allocator.free(request_id)
      return response
    end
    
    
    def submit_inbound_message(message)
      raise unless message['request_id']
      if message['request_id'].local?
        @semaphore.synchronize do
          @pending_requests[message['request_id'].number].resume(message)
        end
        return nil
      else
        case message['type']
        when 'call'
          response_message = Request::InboundCall.process(@connection, message)
        when 'entry'
          response_message = Request::InboundEntry.process(@connection, message)
        else
          raise
        end
        response_message['request_id'] = message['request_id']
        return response_message
      end
    end
    
    
  end
end
