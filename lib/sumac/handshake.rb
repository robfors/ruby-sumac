module Sumac
  class Handshake
    include Emittable
    
    def initialize(orchestrator)
      raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
      @orchestrator = orchestrator
      @compatibility_synchronizer = Synchronizer.new(@orchestrator, Message::Exchange::CompatibilityNotification)
      @initialization_synchronizer = Synchronizer.new(@orchestrator, Message::Exchange::InitializationNotification)
    end
    
    def initiate
      confirm_compatibility
      nil
    end
    
    def active?
      !@initialization_synchronizer.synchronized?
    end
    
    def receive(exchange)
      case exchange
      when Message::Exchange::CompatibilityNotification
        @compatibility_synchronizer.receive(exchange)
      when Message::Exchange::InitializationNotification
        @initialization_synchronizer.receive(exchange)
      else
        raise MessageError
      end
      nil
    end
    
    private
    
    def confirm_compatibility
      @compatibility_synchronizer.local_notification.protocol_version = 1
      @compatibility_synchronizer.initiate
      @compatibility_synchronizer.on(:synchronized) { compatibility_synchronized }
      nil
    end
    
    def compatibility_synchronized
      #close unless @compatibility_synchronizer.remote_notification.protocol_version == 1
      @initialization_synchronizer.local_notification.entry = @orchestrator.local_entry
      @initialization_synchronizer.initiate
      @initialization_synchronizer.on(:synchronized) { initialization_synchronized }
      nil
    end
    
    def initialization_synchronized
      @orchestrator.remote_entry = @initialization_synchronizer.remote_notification.entry
      trigger(:completed)
      nil
    end
    
  end
end
