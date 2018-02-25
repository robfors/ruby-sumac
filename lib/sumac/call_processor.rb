class Sumac
  class CallProcessor
    include Emittable
    
    def initialize(connection)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
      @pending_calls = 0
    end
    
    def any_calls_processing?
      @pending_calls > 0
    end
    
    def receive(exchange)
      raise MessageError unless exchange.is_a?(Message::Exchange::CallRequest)
      raise MessageError unless @connection.at?([:active, :initiate_shutdown])
      raise MessageError unless exchange.exposed_object.is_a?(ExposedObject)
      response = process(exchange)
      @connection.messenger.send(response) if response
      finished
      nil
    end
    
    private
    
    def process(request)
      @pending_calls += 1
      response = Message::Exchange::CallResponse.new(@connection)
      response.id = request.id
      # validate_exposed_object_exist
      begin
        exposed_object = request.exposed_object
      rescue MessageError
        response.exception = MessageError.new
        return response
      end
      # validate_method_exposed
      unless request.exposed_object.__exposed_methods__.include?(request.method_name)
        response.exception = NoMethodError.new
        return response
      end
      # validate_arguments
      @connection.local_references.start_transaction
      @connection.remote_references.start_transaction
      begin
        arguments = request.arguments
      rescue StandardError => e
        response.exception = e
        @connection.local_references.rollback_transaction
        @connection.remote_references.rollback_transaction
        return response
      else
        @connection.local_references.commit_transaction
        @connection.remote_references.commit_transaction
      end
      # call method
      @connection.mutex.unlock
      begin
        return_value = exposed_object.__send__(request.method_name, *arguments)
      rescue StandardError => e
        exception_raised = e
      end
      @connection.mutex.lock
      return if @connection.at?(:kill)
      if exception_raised
        response.exception = exception_raised
        return response
      else
        @connection.local_references.start_transaction
        @connection.remote_references.start_transaction
        begin
          response.return_value = return_value
        rescue StandardError => e # MessageError, StaleObjectError, UnexposableError
          response.exception = e
          @connection.local_references.rollback_transaction
          @connection.remote_references.rollback_transaction
          return response
        else
          @connection.local_references.commit_transaction
          @connection.remote_references.commit_transaction
        end
      end
      return response
    end
    
    def finished
      @pending_calls -= 1
      @connection.closer.job_finished
    end
    
  end
end
