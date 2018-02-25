module Sumac
  class InboundExchangeManager
  
    def initialize(connection)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @semaphore = Mutex.new
      @pending_exchanges = []
    end
    
    def submit(exchange)
      raise unless exchange.is_a?(Exchange)
      @semaphore.synchronize do
        # we should dispatch a thread here
        exchange.process
        @pending_exchanges.delete(exchange)
      end
      nil
    end
    
  end
end
