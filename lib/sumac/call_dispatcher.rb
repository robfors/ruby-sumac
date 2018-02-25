class Sumac
  class CallDispatcher
    
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
    
    def make_call(remote_object, method_name, arguments)
      raise unless remote_object.is_a?(RemoteObject) || remote_object.is_a?(RemoteObjectChild)
      raise ClosedError unless @connection.at?(:active)
      id = @id_allocator.allocate
      request = Message::Exchange::CallRequest.new(@connection)
      request.id = id
      @connection.local_references.start_transaction
      @connection.remote_references.start_transaction
      begin
        request.exposed_object = remote_object
        request.method_name = method_name
        request.arguments = arguments
      rescue StandardError => e # MessageError, StaleObjectError
        @connection.local_references.rollback_transaction
        @connection.remote_references.rollback_transaction
        raise e
      else
        @connection.local_references.commit_transaction
        @connection.remote_references.commit_transaction
      end
      @connection.messenger.send(request)
      raise ClosedError if @connection.at?([:kill, :close])
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
    
  end
end
