module Sumac
  module Exchange
    class InboundRequestManager
    
      def initialize(connection)
        raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
        @connection = connection
        @semaphore = Mutex.new
      end
      
      def submit_request(request)
        raise unless request.kind_of?(Request::Request)
        # we should dispatch a thread here
        response = request.process
        @connection.exchange_router.send(response)
      end
      
    end
  end
end
