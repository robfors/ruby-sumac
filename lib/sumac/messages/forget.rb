module Sumac
  module Messages

    # Representes a _Sumac_ +forget+ message.
    # @api private
    class Forget < Message

      # Build a new {Forget} message.
      # @param object [#origin#id] reference of the object to be forgoten
      # @return [Forget]
      def self.build(object: )
        object = Component::Exposed.from_object(object)
        new(object: object)
      end

      # Build a {Forget} message from the properties of a received _Sumac_ +forget+ message.
      # @param properties [Hash] properties received from remote endpoint
      # @raise [ProtocolError] if a property is missing or unexpected for this message type
      # @raise [ProtocolError] if +object+ property is invalid
      # @return [Forget]
      def self.from_properties(properties)
        raise ProtocolError unless properties.keys.length == 2
        object = Component.from_properties(properties['object'])
        raise ProtocolError unless object.is_a?(Component::Exposed)
        new(object: object)
      end

      # Get a reference of the object being forgoten.
      # @return [Component::Exposed]
      def object
        @object.object
      end

      # Returns a +Hash+ of properties that can be converted into
      # a json string to make a _Sumac_ +forget+ message.
      # @return [Hash]
      def properties
        { 'message_type' => 'forget', 'object' => @object.properties }
      end

    end

  end
end
