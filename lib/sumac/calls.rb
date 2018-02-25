class Sumac
  class Calls
    include StateMachine
    
    state :initiated, initial: true
    state :listening
    state :closing
    state :closed
    
    transition from: :initiated, to: [:listening, :closed]
    transition from: :listening, to: [:closing, :closed]
    transition from: :closing, to: :closed
    
    on_transition(from: :active, to: [:forget_requested, :stale]) do
      send_forget_notification
    end
    
    on_transition(to: :stale) do
      remove
      @forget_condition_variable.broadcast
    end
    
    def initialize(connection)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @pending_requests = {}
      @id_allocator = IDAllocator.new
    end
    
    def any_calls_pending?
      @pending_requests.any?
    end
    
    def kill_all
      raise unless @connection.at?(:kill)
      @pending_requests.each do |id, waiter|
        @pending_requests.delete(id)
        waiter.resume(nil)
      end
    end
    
    def new(exposed_object, method_name, arguments)
      raise if at?(:initiated)
      raise ClosedError if at?([:closing, :closed])
    end
    
    def receive(message)
      raise if at?(:initiated)
      raise MessageError if at?(:closed)
    end
    
    def call(message)
      
    end
    
    
  end
end
