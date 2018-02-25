class Sumac
  class Reference
    include StateMachine
    
    state :active, initial: true
    state :initiate_forget
    state :stale
    
    transition from: :active, to: [:initiate_forget, :stale]
    transition from: :initiate_forget, to: :stale
    
    on_transition(from: :active) do
      send_forget_notification
    end
    
    on_transition(to: :stale) do
      quietly_forget
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
    
    def update
      raise if at?(:stale) # should have been removed by now
      case @connection.at.to_sym
      when :initiate_shutdown, :shutdown
        quietly_to(:initiate_forget)
      when :kill, :close
        quietly_to(:initiate_forget)
        to(:stale)
      end
    end
    
    def local_forget_request
      return if at?(:stale)
      to(:initiate_forget) unless at?(:initiate_forget)
      return if at?(:stale)
      @forget_condition_variable.wait(@connection.mutex)
    end
    
    def remote_forget_request
      raise if at?(:stale)
      to(:stale)
    end
    
    def send_forget_notification
      message = Message::Exchange::ForgetNotification.new(@connection)
      message.reference = self
      @connection.messenger.send(message)
    end
    
    def quietly_forget
      quietly_to(:stale)
      @forget_condition_variable.signal
    end
    
    def callable?
      at?(:active)
    end
    
  end
end
