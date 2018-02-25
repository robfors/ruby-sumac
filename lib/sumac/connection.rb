module Sumac
  class Connection
    include Emittable
    
    def initialize(socket, local_entry = nil)
      @orchestrator = Orchestrator.new(self, socket, local_entry)
      @orchestrator.start
      @shutdown_waiter = Waiter.new
    end
    
    def close
      @orchestrator.mutex.synchronize do
        @orchestrator.shutdown.initiate
        @orchestrator.on(:close_complete) { @shutdown_waiter.resume }
      end
      @shutdown_waiter.wait
      nil
    end
    
    def entry
      @orchestrator.mutex.synchronize { @orchestrator.remote_entry }
    end
    
  end
end
