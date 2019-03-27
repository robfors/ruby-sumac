module Sumac
  
  # Acts as the backend to {ObjectRequestBroker} to hide implementation from the application.
  # It is responsible for handling all events directed to the broker.
  # It also shares access to all its helpers.
  # It should only have methods that effect the broker's state. Other methods should be called on
  # the relevant helper directly.
  # @api private
  class Connection
    extend Forwardable

    # Build a new {Connection}.
    # @param local_entry [Array,Boolean,Exception,ExposedObject,Float,Hash,Integer,nil,String] object to expose to the remote endpoint
    # @param message_broker [#close,#kill,#object_request_broker=,#send] interface to the messenger
    # @param object_request_broker [ObjectRequestBroker]
    # @raise [TypeError] if any methods are missing on +message_broker+
    # @raise [UnexposedObjectError] if local entry object is invalid
    # @return [Connection]
    def initialize(local_entry: , message_broker: , object_request_broker: )
      @local_entry = local_entry
      @message_broker = message_broker
      @object_request_broker = object_request_broker
      @calls = Calls.new(self)
      @closer = Closer.new(self)
      @handshake = Handshake.new(self)
      @messenger = Messenger.new(self)
      @objects = Objects.new(self)
      @remote_entry = RemoteEntry.new
      @scheduler = Scheduler.new(self)
      @shutdown = Shutdown.new(self)
      validate
    end

    # @!method any_calls?
    #   @see Calls#any?
    def_delegator :@calls, :any?, :any_calls?

    # @!method cancel_local_calls
    #   @see Calls#cancel_local
    def_delegator :@calls, :cancel_local, :cancel_local_calls

    # @!method cancel_remote_entry
    #   @see RemoteEntry#cancel
    def_delegator :@remote_entry, :cancel, :cancel_remote_entry

    # Request the {Connection} to close.
    # @return [void]
    def close
      @scheduler.receive(:close)
    end

    # Returns the {Closer} helper.
    # @return [Closer]
    attr_reader :closer

    # @!method close_messenger
    #   @see Messenger#close
    def_delegator :@messenger, :close, :close_messenger

    # @!method enable_close_requests
    #   @see Closer#enable
    def_delegator :@closer, :enable, :enable_close_requests

    # Request the +object+ to be forgoten.
    # @param object [ExposedObject]
    # @raise [UnexposedObjectError] if +object+ is not an exposed object or does not belong to this {Connection}
    # @return [QuackConcurrency::Future]
    def forget(object)
      @scheduler.receive(:forget, object)
    end

    # @!method forget_objects
    #   @see Objects#forget
    def_delegator :@objects, :forget, :forget_objects

    # Request the {Connection} to start.
    # Starts the messenger and sends the first message.
    # @return [void]
    def initiate
      @scheduler.receive(:initiate)
    end

    # Request the {Connection} to be killed.
    # The thread will wait but be queued as first in line if another event is being processed.
    # @return [void]
    def kill
      @scheduler.receive(:kill)
    end

    # @!method kill_messenger
    #   @see Messenger#kill
    def_delegator :@messenger, :kill, :kill_messenger

    # @!method killed?
    #   @see Closer#killed?
    def_delegator :@closer, :killed?

    # Returns the entry object given by the local application.
    # @return [Array,Boolean,Exception,ExposedObject,Float,Hash,Integer,nil,String]
    attr_reader :local_entry

    # @!method mark_as_closed
    #   @see Closer#closed
    def_delegator :@closer, :closed, :mark_as_closed

    # @!method mark_as_killed
    #   @see Closer#killed
    def_delegator :@closer, :killed, :mark_as_killed

    # @!method mark_messenger_as_closed
    #   @see Messenger#closed
    def_delegator :@messenger, :closed, :mark_messenger_as_closed

    # Returns the {Messenger} helper.
    # @return [Messenger]
    attr_reader :messenger

    # Returns the message broker for the conneciton.
    attr_reader :message_broker

    # Inform the {Connection} that the messenger has closed.
    # @return [void]
    def messenger_closed
      @scheduler.receive(:messenger_closed)
    end

    # @!method messenger_closed?
    #   @see Messenger#closed?
    def_delegator :@messenger, :closed?, :messenger_closed?

    # Inform the {Connection} that the messenger has been killed.
    # @return [void]
    def messenger_killed
      @scheduler.receive(:messenger_killed)
    end

    # Returns the {ObjectRequestBroker} that this {Connection} belongs to.
    # @return [ObjectRequestBroker]
    attr_reader :object_request_broker

    # Returns the {Objects} helper.
    # @return [Objects]
    attr_reader :objects

    # @!method process_call_request
    #   @see Calls#process_request
    def_delegator :@calls, :process_request, :process_call_request

    # @!method process_call_request_message
    #   @see Calls#process_request_message
    def_delegator :@calls, :process_request_message, :process_call_request_message

    # @!method process_call_response
    #   @see Calls#process_response
    def_delegator :@calls, :process_response, :process_call_response

    # @!method process_call_response_message
    #   @see Calls#process_response_message
    def_delegator :@calls, :process_response_message, :process_call_response_message

    # @!method process_compatibility_message
    #   @see Handshake#process_compatibility_message
    def_delegator :@handshake, :process_compatibility_message

    # @!method process_forget
    #   @see Objects#process_forget
    def_delegator :@objects, :process_forget

    # @!method process_forget_message
    #   @see Objects#process_forget_message
    def_delegator :@objects, :process_forget_message

    # @!method process_initialization_message
    #   @see Handshake#process_initialization_message
    def_delegator :@handshake, :process_initialization_message

    # Submit a message from the messenger.
    # The thread will wait its turn if another event is being processed.
    # @param message_string [String]
    # @return [void]
    def messenger_received_message(message_string)
      #puts "receive|#{message_string}"
      begin
        message = Messages.from_json(message_string)
      rescue ProtocolError
        @scheduler.receive(:invalid_message)
        return
      end
      case message
      when Messages::CallRequest then @scheduler.receive(:call_request_message, message)
      when Messages::CallResponse then @scheduler.receive(:call_response_message, message)
      when Messages::Compatibility then @scheduler.receive(:compatibility_message, message)
      when Messages::Forget then @scheduler.receive(:forget_message, message)
      when Messages::Initialization then @scheduler.receive(:initialization_message, message)
      when Messages::Shutdown then @scheduler.receive(:shutdown_message)
      end    
    end

    # Returns the {RemoteEntry} helper.
    # @return [RemoteEntry]
    attr_reader :remote_entry

    # Submit a response of a remote call that has finished.
    # @param call [RemoteCall]
    # @return [void]
    def respond_to_call(call)
      @scheduler.receive(:call_response, call)
    end

    # Submit a request for a new call.
    # Returns a future for the return value of the call.
    # @param request [Hash] call parameters: object, method, arguments
    # @raise [ClosedObjectRequestBrokerError] if connection closed before respose was received
    # @raise [RemoteError] if error was raised during call
    # @return [QuackConcurrency::Future]
    def request_call(request)
      @scheduler.receive(:call_request, request)
    end

    # @!method send_compatibility_message
    #   @see Handshake#send_compatibility_message
    def_delegator :@handshake, :send_compatibility_message

    # @!method send_initialization_message
    #   @see Handshake#send_initialization_message
    def_delegator :@handshake, :send_initialization_message

    # @!method setup_messenger
    #   @see Messenger#setup
    def_delegator :@messenger, :setup, :setup_messenger

    # @!method send_shutdown_message
    #   @see Shutdown#send_message
    def_delegator :@shutdown, :send_message, :send_shutdown_message

    # Validate a call request before it starts.
    # @param call [RemoteCall]
    # @return [Boolean] if call request is valid
    def validate_request(call)
      @calls.validate_request(call)
    end

    private

    # Validates that the message broker and local entry.
    # To be called before the broker is initiated.
    # @raise [TypeError] if any methods are missing from message broker
    # @raise [UnexposedObjectError] if local entry object is invalid
    # @return [void]
    def validate
      @messenger.validate_message_broker
      @handshake.validate_local_entry
    end

  end

end
