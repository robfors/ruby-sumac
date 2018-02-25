class Sumac
  class Scheduler
  
    def initialize(connection, worker_count)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @worker_pool = WorkerPool.new(worker_count)
      @dispatch_worker = nil
    end
    
    def run
      @dispatch_worker = Thread.new do
        @connection.mutex.synchronize do
          raise unless @connection.at?(:initial)
          @connection.to(:compatibility_handshake)
        end
        receiver_loop
      end
      nil
    end
    
    def receiver_loop
      loop do
        begin
          message_string = @connection.messenger_adapter.receive
        rescue Adapter::ClosedError
          @connection.mutex.synchronize do
            unless @connection.at?([:kill, :close])
              @connection.to(:kill)
            end
          end
        end
        break if @connection.mutex.synchronize { @connection.at?([:kill, :close]) }
        dispatch(message_string)
      end
      nil
    end
    
    def dispatch(message_string)
      #@worker_pool.run do
        @connection.mutex.synchronize do
          break if @connection.at?([:kill, :close])
          @connection.messenger.receive(message_string)
        end
      #end
      nil
    end
    
    def join
      @dispatch_worker.join
      @worker_pool.join
      nil
    end
    
  end
end
