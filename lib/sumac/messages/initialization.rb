module Sumac
  module Messages

    # Representes a _Sumac_ +initialization+ message.
    # @api private
    class Initialization < Message

      # Build a new {Initialization} message.
      # @param entry [Array,Boolean,Exception,Float,Hash,Integer,nil,#origin#id,String] the inial object to pass to the remote application
      # @return [Initialization]
      def self.build(entry: )
        entry = Component.from_object(entry)
        new(entry: entry)
      end

      # Build a {Initialization} message from the properties of a received _Sumac_ +initialization+ message.
      # @param properties [Hash] properties received from remote endpoint
      # @raise [ProtocolError] if a property is missing or unexpected for this message type
      # @raise [ProtocolError] if +entry+ is invalid
      # @return [Initialization]
      def self.from_properties(properties)
        raise ProtocolError unless properties.keys.length == 2
        raise ProtocolError unless properties['entry'].is_a?(Hash)
        entry = Component.from_properties(properties['entry'])
        new(entry: entry)
      end

      # Get the inital object passed by the remote application.
      # @return [Array,Boolean,Component::Exposed,Exception,Float,Hash,Integer,nil,String]
      def entry
        @entry.object
      end

      # Returns a +Hash+ of properties that can be converted into
      # a json string to make a Sumac compatibility message.
      # @return [Hash]
      def properties
        { 'message_type' => 'initialization', 'entry' => @entry.properties }
      end

    end

  end
end
