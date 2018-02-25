module Sumac
  class Shutdown
    
    def initialize(orchestrator)
      raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
      @orchestrator = orchestrator
      @synchronizer = Synchronizer.new(@orchestrator, Message::Exchange::ShutdownNotification)
      @synchronizer.on(:synchronized) { synchronized }
      @shutdown_triggered = false
    end
    
    def initiate
      raise if @orchestrator.handshake.active?
      unless @synchronizer.initiated?
        @synchronizer.initiate
        @orchestrator.connection.trigger(:shutdown)
        @shutdown_triggered = true
      end
      nil
    end
    
    def initiated?
      @synchronizer.initiated?
    end
    
    def active?
      @synchronizer.synchronized?
    end
    
    def receive(exchange)
      raise MessageError if @orchestrator.handshake.active?
      @synchronizer.receive(exchange)
      nil
    end
    
    private
    
    def synchronized
      unless @shutdown_triggered
        @orchestrator.connection.trigger(:shutdown)
        @shutdown_triggered = true
      end
      @orchestrator.call_dispatcher.on(:request_completed) { try_close }
      @orchestrator.call_processor.on(:exchange_processed) { try_close }
      try_close
      nil
    end
    
    def try_close
      @orchestrator.close if can_close?
      nil
    end
    
    def can_close?
      !@orchestrator.call_dispatcher.any_calls_pending? &&
        !@orchestrator.call_processor.any_calls_processing?
    end
    
  end
end
