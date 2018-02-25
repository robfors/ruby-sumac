module Sumac
  class InboundRequestManager
    
    
    def initialize(connection)
      @connection = connection
      @pending_requests = {}
      @semaphore = Mutex.new
    end
    
    
    def submit_request(message)
      @semaphore.synchronize do
        raise if @pending_requests[request.sequence_number]
        request = InboundRequest.new(@connection, message)
        @pending_requests[request.sequence_number] = request
        request.async.process
      end
    end
    
    
    def submit_response(message)
      @semaphore.synchronize do
        @connection.message_manager.submit(message)
        @pending_requests[message.sequence_number].terminate
        @pending_requests.delete(message.sequence_number)
      end
    end
    
    
  end
end
