module Sumac
  class OutboundRequestManager
    
    def initialize(connection)
      @connection = connection
      @semaphore = Mutex.new
      @pending_requests = {}
      @sequence_number_manager = SequenceNumberManager.new
    end
    
    def submit_request(request)
      request.sequence_number = @sequence_number_manager.generate_sequence_number
      semaphore.synchronize do
        @pending_requests[request.sequence_number] = request
      end
      @connection.message_manager.send_message(request)
    end
    
    def submit_response(response)
      semaphore.synchronize do
        @pending_requests[response.sequence_number].submit_response(response)
        @pending_requests.delete(response.sequence_number)
      end
    end
    
  end
end
