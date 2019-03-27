module Sumac
  module Messages

    # Representes a _Sumac_ +shutdown+ message.
    # @api private
    class Shutdown < Message

      # Build a new {Shutdown} message.
      # @return [Shutdown]
      def self.build
        new
      end

      # Build a {Shutdown} message from the properties of a received _Sumac_ +shutdown+ message.
      # @param properties [Hash] properties received from remote endpoint
      # @raise [ProtocolError] if a property is missing or unexpected for this message type
      # @return [Shutdown]
      def self.from_properties(properties)
        raise ProtocolError unless properties.keys.length == 1
        new
      end

      # Returns a +Hash+ of properties that can be converted into
      # a json string to make a _Sumac_ +compatibility+ message.
      # @return [Hash]
      def properties
        { 'message_type' => 'shutdown' }
      end

    end

  end
end
