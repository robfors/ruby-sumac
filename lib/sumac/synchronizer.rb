module Sumac
  class Synchronizer
    include Emittable
    
    attr_reader :local_notification, :remote_notification
    
    def initialize(orchestrator, notification_class, id = nil)
      raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
      @orchestrator = orchestrator
      raise unless notification_class.ancestors.include?(Message::Exchange::Notification)
      @notification_class = notification_class
      @id = id
      if @id
        @local_notification = @notification_class.new(@orchestrator, @id)
      else
        @local_notification = @notification_class.new(@orchestrator)
      end
      @remote_notification = nil
      #@state = :initialized
      @state = :listening
      @orchestrator.receiver.register(@notification_class, @id, self)
    end
    
    def listen
      raise unless @state == :initialized
      @state = :listening
    end
    
    def initiate
      raise unless @state.one_of?(:initialized, :listening)
      transmit_notification
      @state = :initiated
      nil
    end
    
    def initiated?
      @state.one_of?(:initiated, :synchronized)
    end
    
    def receive(exchange)
      raise MessageError unless exchange.kind_of?(@notification_class)
      trigger(:received)
      case @state
      when :listening
        @remote_notification = exchange
        transmit_notification
        @state = :synchronized
        trigger(:synchronized)
      when :initiated
        @remote_notification = exchange
        @state = :synchronized
        trigger(:synchronized)
      else
        raise MessageError
      end
    end
    
    def synchronized?
      @state == :synchronized
    end
    
    private
    
    def transmit_notification
      @orchestrator.transmitter.transmit(@local_notification)
      nil
    end
    
  end
end
