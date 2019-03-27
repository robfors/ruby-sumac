module Sumac

  # Manages handshake of {Connection}.
  # @api private
  class Handshake

    # Build a new {Handshake} manager.
    # @param connection [Connection] being managed
    # @return [Handshake]
    def initialize(connection)
      @connection = connection
    end

    # Build and send a compatibility message.
    # @return [void]
    def send_compatibility_message
      message = Messages::Compatibility.build(protocol_version: '0')
      @connection.messenger.send(message)
    end

    # Build and send an initialization message.
    # @note make sure +@connection.local_entry+ is sendable before calling this
    # @return [void]
    def send_initialization_message
      entry_properties = @connection.objects.convert_object_to_properties(@connection.local_entry)
      message = Messages::Initialization.build(entry: entry_properties)
      @connection.messenger.send(message)
    end

    # Processes a compatibility message from the remote endpoint.
    # @param message [Messages::Compatibility]
    # @raise [ProtocolError] if not compatible
    # @return [void]
    def process_compatibility_message(message)
      raise ProtocolError unless message.protocol_version == '0'
    end

    # Processes a initialization message from the remote endpoint.
    # @param message [Messages::Initialization]
    # @raise [ProtocolError] if a {LocalObject} does not exist with id received for the entry object
    # @return [void]
    def process_initialization_message(message)
      entry = @connection.objects.convert_properties_to_object(message.entry)
      @connection.remote_entry.set(entry)
    end

    # Validate that the local entry will be sendable when the compatibility message is sent.
    # @raise [UnexposedObjectError] if local entry object is invalid
    # @return [void]
    def validate_local_entry
      @connection.objects.ensure_sendable(@connection.local_entry)
    end

  end

end
