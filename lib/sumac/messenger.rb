module Sumac

  # Interfaces with the messenger via the message broker.
  # @api private
  class Messenger

    # Build a new {Messenger}.
    # @param connection [Connection] that the messenger belongs to
    # @return [Messenger]
    def initialize(connection)
      @connection = connection
      @ongoing = true
    end

    # Requests the messenger to close.
    # To be called by {Connection} when changing states.
    # @note should not be called after {#closed} is called
    # @return [void]
    def close
      @connection.message_broker.close
    end

    # Update the observed status of the messenger.
    # @return [void]
    def closed
      @ongoing = false
    end

    # Returns if the messenger has notified the {Connection} that it has closed.
    # @return [Boolean]
    def closed?
      @ongoing
    end

    # Demand the messenger to terminate immediately.
    # To be called by {Connection} when it is killed.
    # @note should not be called after {#closed} is called
    # @return [void]
    def kill
      @connection.message_broker.kill
    end

    # Send a message to the messenger via the message broker.
    # @note must never raise an error, if the network connection has died during this call
    #   or the messenger terminated for any reason {ObjectRequestBroker#messenger_killed} is expected be called soon
    # @note should not be called after {#closed} is called
    # @param message [Messages::Message]
    # @return [void]
    def send(message)
      message_string = message.to_json
      @connection.message_broker.send(message_string)
    end

    # Setup the message broker so it can send events to the broker.
    # @return [void]
    def setup
      @connection.message_broker.object_request_broker = @connection.object_request_broker
    end

    # Validates that the message broker will respond to the necessary methods.
    # @raise [TypeError] if any methods are missing
    # @return [void]
    def validate_message_broker
      message_broker = @connection.message_broker
      raise TypeError, "'message_broker' must respond to #close" unless message_broker.respond_to?(:close)
      raise TypeError, "'message_broker' must respond to #kill" unless message_broker.respond_to?(:kill)
      raise TypeError, "'message_broker' must respond to #object_request_broker=" unless message_broker.respond_to?(:object_request_broker=)
      raise TypeError, "'message_broker' must respond to #send" unless message_broker.respond_to?(:send)
    end

  end

end
