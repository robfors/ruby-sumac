module Sumac
  class OutboundRequestManager
    
    
    def initialize(connection)
      @connection = connection
      @pending_requests = {}
      @id_manager = IDManager.new
      @semaphore = Mutex.new
    end
    
    
    def submit_request(request)
      @semaphore.synchronize do
        request.sequence_number = @id_manager.allocate
        @pending_requests[request.sequence_number] = request
        @connection.message_manager.submit(request.message)
      end
    end
    
    
    def submit_response(message)
      @semaphore.synchronize do
        @pending_requests[message.sequence_number].submit_response(message)
        @pending_requests.delete(message.sequence_number)
        @id_manager.free(message.sequence_number)
      end
    end
    
    
  end
end
