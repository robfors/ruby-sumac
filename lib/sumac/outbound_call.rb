class Sumac
  class OutboundCall
    include StateMachine
    
    state :building, initial: true
    state :waiting
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
    
    def initialize(connection, remote_object, method_name, arguments)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      raise unless remote_object.is_a?(RemoteObject)
      @remote_object = remote_object
      @method_name = method_name
      @arguments = arguments
      @request = Message::Exchange::CallRequest.new(@connection)
    end
    
    def run
      @connection.mutex.synchronize do
        raise ClosedError unless @connection.at?(:active)
        id = @connection.calls.register(self)
        request.id = id
        
      
    def validate_remote_object
      @request.exposed_object = @remote_object
    end
    
    def build
      @connection.local_references.start_transaction
      @connection.remote_references.start_transaction
      begin
        request.exposed_object = exposed_object
        request.method_name = method_name
        request.arguments = arguments
      rescue StandardError => e # MessageError, StaleObjectError
        @connection.local_references.rollback_transaction
        @connection.remote_references.rollback_transaction
        @connection.closer.job_finished
        raise e
      else
        @connection.local_references.commit_transaction
        @connection.remote_references.commit_transaction
      end
    
    def make_call(exposed_object, method_name, arguments)
      
      
      
      
      @connection.messenger.send(request)
      if @connection.at?([:kill, :close])
        raise ClosedError
        @connection.closer.job_finished
      end
      waiter = QuackConcurrency::Waiter.new
      @pending_requests[id] = waiter
      @connection.mutex.unlock
      response = waiter.wait
      @connection.mutex.lock
      @id_allocator.free(id)
      @connection.closer.job_finished
      raise ClosedError if response == nil
      raise response.exception if response.exception
      response.return_value
    ensure
      @id_allocator.free(id) if id && @id_allocator.allocated?(id)
    end
    
    def receive(exchange)
      raise MessageError unless @connection.at?([:active, :initiate_shutdown, :shutdown])
      raise MessageError unless exchange.is_a?(Message::Exchange::CallResponse)
      waiter = @pending_requests[exchange.id]
      @pending_requests.delete(exchange.id)
      raise MessageError unless waiter
      waiter.resume(exchange)
      nil
    end
    
    def cancel
    end
    
  end
end
