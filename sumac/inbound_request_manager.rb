module Sumac
  class InboundRequestManager
    
    def initialize(connection)
      @connection = connection
      @semaphore = Mutex.new
      @pending_requests = {}
    end
    
    def submit_request(request)
      semaphore.synchronize do
        @pending_requests[request.sequence_number] = request
      end
      request.async.process
    end
    
    def submit_response(response)
      semaphore.synchronize do
        @pending_requests.delete(response.sequence_number)
      end
      @connection.message_manager.send_message(request)
    end
    
  end
end
