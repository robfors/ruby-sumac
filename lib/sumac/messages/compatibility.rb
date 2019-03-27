module Sumac
  module Messages

    # Representes a _Sumac_ +compatibility+ message.
    # @api private
    class Compatibility < Message

      # Build a new {Compatibility} message.
      # @param protocol_version [String]
      # @return [Compatibility]
      def self.build(protocol_version: )
        new(protocol_version: protocol_version)
      end

      # Build a {Compatibility} message from the properties of a received _Sumac_ +compatibility+ message.
      # @param properties [Hash] properties received from remote endpoint
      # @raise [ProtocolError] if a property is missing or unexpected for this message type
      # @raise [ProtocolError] if +protocol_version+ property is invalid (must be a +String+)
      # @return [Compatibility]
      def self.from_properties(properties)
        raise ProtocolError unless properties.keys.length == 2
        raise ProtocolError unless properties['protocol_version'].is_a?(String)
        new(protocol_version: properties['protocol_version'])
      end

      # Returns a +Hash+ of properties that can be converted into
      # a json string to make a _Sumac_ +compatibility+ message.
      # @return [Hash]
      def properties
        { 'message_type' => 'compatibility', 'protocol_version' => @protocol_version }
      end

      # Returns the +protocol_version+ property given by the remote the message.
      # @return [String]
      def protocol_version
        @protocol_version
      end

    end

  end
end
