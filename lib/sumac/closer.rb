class Sumac
  class Closer
  
    def initialize(connection)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @future = QuackConcurrency::Future.new
    end
    
    def job_finished
      try_close if @connection.at?([:shutdown, :kill])
      nil
    end
    
    def try_close
      @connection.to(:close) if can_close?
      nil
    end
    
    def close
      @connection.mutex.synchronize do
        case @connection.at.to_sym
        when :initial, :compatibility_handshake, :initialization_handshake
          @connection.to(:kill)
        when :active
          @connection.to(:initiate_shutdown)
        end
      end
      @future.get
      @connection.scheduler.join
      nil
    end
    
    def complete
      @future.set
      nil
    end
    
    def join
      @future.get
      @connection.scheduler.join
      nil
    end
    
    private
    
    def can_close?
      !@connection.call_dispatcher.any_calls_pending? &&
        !@connection.call_processor.any_calls_processing?
    end
    
  end
end
