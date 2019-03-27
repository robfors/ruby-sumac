module Sumac

  # The interface for appliction and message_broker.
  # @note it is the frontend of {Connection} so most of those methods won't be exposed directly
  class ObjectRequestBroker
    extend Forwardable

    # Build a new {ObjectRequestBroker}.
    # @param entry [Array,Boolean,Exception,ExposedObject,Float,Hash,Integer,nil,String] initial object to give to the remote endpoint
    # @param message_broker [#close,#kill,#object_request_broker=,#send] interface to the messenger
    # @raise [UnexposedObjectError] if entry object is invalid
    # @raise [TypeError] if any methods are missing on +message_broker+
    # @return [ObjectRequestBroker]
    def initialize(entry: , message_broker: )
      @connection = Connection.new(local_entry: entry, message_broker: message_broker, object_request_broker: self)
      @directive_queue = DirectiveQueue.new
      initiate
    end

    # Submit a request for a new call.
    # The thread will wait its turn if another event is being processed.
    # @note will block until the response is available
    # Returns the return value of the call or raises the error raised during the call.
    # @api private
    # @param request [Hash]
    # @raise [ClosedObjectRequestBrokerError] if connection closed before respose was received
    # @raise [RemoteError] if error was raised during call
    # @raise [ArgumentError,StaleObjectError,UnexposedMethodError,UnexposedObjectError] if one is raised when trying
    #   to call the method or return a value (but not during the call)
    # @return [Array,Boolean,Exception,ExposedObject,Float,Hash,Integer,nil,String]
    def call(request)
      future = @directive_queue.execute { @connection.request_call(request) }
      future.get
    end

    # Closes the broker.
    # A broker can only be closed after the handshake. If the application needs to prematurely close the broker
    # than {#kill} should be used.
    # The thread will wait its turn if another event is being processed.
    # @note will block until the broker, its calls and the messenger have all ended
    # @return [void]
    def close
      @connection.closer.wait_until_enabled
      @directive_queue.execute { @connection.close }
      join
    end

    # Returns if the broker has closed.
    # Will return +false+ until all calls have finished and the messenger has closed.
    # Will return +true+ even if it has been killed.
    # The thread will wait its turn if another event is being processed.
    # @note This call is queued. Consider the case where a local call is canceled, the application's
    #   thread may immediately then check if see if the broker has closed. If the broker is marked as
    #   closed after all the calls are canceled the application will not know why the call was canceled.
    #   This call is queued so we don't need to worry about the order of actions completed during a transition.
    # @return [Boolean]
    def closed?
      @directive_queue.execute { @connection.closer.closed? }
    end

    # Get the entry object of the remote application.
    # @return [Array,Boolean,Exception,ExposedObject,Float,Hash,Integer,nil,String]
    def entry
      @connection.remote_entry.get
    end

    # Forgets an object.
    # Passing a {LocalObject} will initiate the forget request (it will still be remembered by any other brokers).
    # Passing a {RemoteObject} will work, but generally {RemoteObject#forget} can be used instead.
    # The thread will wait its turn if another event is being processed.
    # @param object
    # @raise [UnexposedObjectError] if +object+ is not an exposed object or does not belong to this broker
    # @return [void]
    def forget(object)
      future = @directive_queue.execute { @connection.forget(object) }
      # future will not be returned if the broker is in 'kill', 'join' or 'close' state
      future.get if future
    end

    # Block until the broker, its calls and the messenger have all ended.
    # @return [void]
    def join
      @connection.closer.join
      # ensure that the thread that closed the broker has a chance to finish the transition
      #   we don't want the application to unknowingly exit the process prematurely
      @directive_queue.execute { nil }
    end

    # Kills the broker.
    # Can be called at any state of the broker. A call on a closed or killed broker
    # will be ignored. It will close the messenger without the remote endpoint confirming the action.
    # The thread will wait but be queued as first in line if another event is being processed.
    # @note Any ongoing remote calls will remain. Call {#join} afterwards to wait for any calls to finish.
    # @return [void]
    def kill
      @directive_queue.execute_next { @connection.kill }
      nil
    end

    # Returns if the the application or messenger requested the broker to be killed.
    # +true+ would indicate that the broker was closed prematurely.
    # @note there may still be some ongoing remote calls even then +true+, call {#join} to wait for them
    # @return [Boolean]
    def killed?
      @directive_queue.execute { @connection.closer.killed? }
    end

    # @!method message_broker
    #   Returns the message broker supplied to the {ObjectRequestBroker}.
    #   @return [Object]
    #   @see Connection#message_broker
    def_delegator :@connection, :message_broker

    # Inform the broker that the messenger has closed.
    # The thread will wait its turn if another event is being processed.
    # @note only one of {#messenger_closed} and {#messenger_killed} should ever be called, and only once
    # @return [void]
    def messenger_closed
      @directive_queue.execute { @connection.messenger_closed }
    end

    # Inform the broker that the messenger has been killed.
    # The thread will wait its turn if another event is being processed.
    # @note only one of {#messenger_closed} and {#messenger_killed} should ever be called, and only once
    # @return [void]
    def messenger_killed
      @directive_queue.execute { @connection.messenger_killed }
    end

    # Inform the broker that the messenger has received a message.
    # The thread will wait its turn if another event is being processed.
    # @note should not be called after {#messenger_closed} or {#messenger_killed}
    # @param message_string [String]
    # @return [void]
    def messenger_received_message(message_string)
      @directive_queue.execute { @connection.messenger_received_message(message_string) }
    end

    # Returns if the object would be allowed to be received from the broker's remote endpoint.
    # Currently only implemented for checking {RemoteObject}s.
    # @api private
    # @param remote_object [RemoreObject]
    # @return [Boolean]
    def receivable?(remote_object)
      @directive_queue.execute { @connection.objects.receivable?(remote_object) }
    end

    # Submit a response of a remote call that has finished.
    # The thread will wait its turn if another event is being processed.
    # @api private
    # @param call [RemoteCall]
    # @return [void]
    def respond(call)
      @directive_queue.execute { @connection.respond_to_call(call) }
    end

    # Returns if the object would be allowed to be sent to the broker's remote endpoint.
    # Accepts any object.
    # @api private
    # @param object [Object]
    # @return [Boolean]
    def sendable?(object)
      @directive_queue.execute { @connection.objects.sendable?(object) }
    end

    # Returns if the object has been forgoten by both endpoints.
    # Only checks {RemoteObject}s.
    # @api private
    # @param remote_object [RemoreObject]
    # @return [Boolean]
    def stale?(remote_object)
      @directive_queue.execute { @connection.objects.stale?(remote_object) }
    end

    # Validate a call request before it starts.
    # The thread will wait its turn if another event is being processed.
    # @api private
    # @param call [RemoteCall]
    # @return [Boolean] if call request is valid
    def validate_request(call)
      @directive_queue.execute { @connection.validate_request(call) }
    end

    private

    # Request the broker to start.
    # Starts the messanger and sends the first message.
    # Should never block as this should be the first event. We do, however, want to lock out the messenger from
    # submitting any events until we can finish this call (which includes sending the first message).
    # @api private
    # @return [void]
    def initiate
      @directive_queue.execute { @connection.initiate }
    end

  end

end
