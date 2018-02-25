class Sumac
  class Shutdown
    
    def initialize(connection)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
    end
    
    #def initiate
      #raise unless @orchestrator.state_machine.at?(:active)
      #@orchestrator.state_machine.to(:initiate_shutdown)
      #nil
    #end
    
    #def initiated?
      #@orchestrator.state_machine.at?([:initiate_shutdown, :shutdown, :close])
    #end
    
    def send_notification
      message = Message::Exchange::ShutdownNotification.new(@connection)
      @connection.messenger.send(message)
      nil
    end
    
    def receive(exchange)
      raise MessageError unless exchange.is_a?(Message::Exchange::ShutdownNotification)
      @connection.to(:shutdown)
      nil
    end
    
  end
end
