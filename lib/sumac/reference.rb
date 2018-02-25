class Sumac
  class Reference
    include StateMachine
    
    state :active, initial: true
    state :forget_requested
    state :detached
    state :stale
    
    transition from: :active, to: [:forget_requested, :detached, :stale]
    transition from: :forget_requested, to: [:detached, :stale]
    transition from: :detached, to: :stale
    
    on_transition(from: :active, to: [:forget_requested, :stale]) do
      send_forget_notification
    end
    
    on_transition(to: :stale) do
      remove
      @forget_condition_variable.broadcast
    end
    
    attr_reader :exposed_id
    
    def initialize(connection, exposed_id)
      super()
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      raise unless exposed_id.is_a?(Integer)
      @exposed_id = exposed_id
      @forget_condition_variable = ConditionVariable.new
    end
    
    def local_forget_request
      to(:forget_requested) if at?(:active)
      @forget_condition_variable.wait(@connection.mutex) if at?([:forget_requested, :detached])
    end
    
    def remote_forget_request
      raise if at?([:detached, :stale])
      to(:stale)
    end
    
    def send_forget_notification
      message = Message::Exchange::ForgetNotification.new(@connection)
      message.reference = self
      @connection.messenger.send(message)
    end
    
    def detach
      to(:detached)
    end
    
    def callable?
      at?(:active)
    end
    
    def destroy
      raise unless at?(:detached)
      to(:stale)
    end
    
    def stale?
      at?(:stale)
    end
    
  end
end
