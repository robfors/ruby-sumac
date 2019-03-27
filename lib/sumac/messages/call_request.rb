module Sumac
  module Messages

    # Representes a _Sumac_ +call_request+ message.
    # @api private
    class CallRequest < Message

      # Build a new {CallRequest} message.
      # @param id [Integer] the id of the call
      # @param object [#origin#id] reference of object whose method is to be called
      # @param method [String] the method that is to be called
      # @param arguments [Array<Array,Boolean,Exception,Float,Hash,Integer,nil,#origin#id,String>] the arguments that will be passed to the method that is to be called
      # @return [CallRequest]
      def self.build(id: , object: , method: , arguments: )
        object = Component.from_object(object)
        arguments = arguments.map { |argument| Component.from_object(argument) }
        new(id: id, object: object, method: method, arguments: arguments)
      end

      # Build a {CallRequest} message from the properties of a received _Sumac_ +call_request+ message.
      # @param properties [Hash] properties received from remote endpoint
      # @raise [ProtocolError] if a property is missing or unexpected for this message type
      # @raise [ProtocolError] if +id+ property is invalid (must be an +Integer+)
      # @raise [ProtocolError] if +object+ property is invalid
      #   (must be a {Component::Exposed} with a +'local'+ origin)
      # @raise [ProtocolError] if +method+ property is invalid
      #   (must be a non empty +String+)
      # @raise [ProtocolError] if +arguments+ property is invalid (must be an +Array+)
      # @raise [ProtocolError] if any +arguments+ property components are invalid
      # @return [CallRequest]
      def self.from_properties(properties)
        raise ProtocolError unless properties.keys.length == 5
        raise ProtocolError unless ID.valid?(properties['id'])
        id = properties['id']
        object = Component.from_properties(properties['object'])
        raise ProtocolError unless object.class.one_of?(Component::Exposed)#, Component::ExposedChild)
        raise ProtocolError unless object.origin == :local
        raise ProtocolError unless properties['method'].is_a?(String)
        raise ProtocolError if properties['method'].empty?
        method = properties['method']
        raise ProtocolError unless properties['arguments'].is_a?(Array)
        arguments = properties['arguments'].map do |argument_properties|
          Component.from_properties(argument_properties)
        end
        new(id: id, object: object, method: method, arguments: arguments)
      end

      # Returns the arguments to be pass to the method when called.
      # @return [Array<Array,Boolean,Component::Exposed,Exception,Float,Hash,Integer,nil,String>]
      def arguments
        @arguments.map { |argument| argument.object }
      end

      # Returns the id of the call.
      # @return [Integer]
      attr_reader :id

      # Returns the method of the call.
      # @return [Integer]
      attr_reader :method

      # Returns the object whose method is requested to be called.
      # @return [Component::Exposed]
      def object
        @object.object
      end

      # Returns a +Hash+ of properties that can be converted into
      # a json string to make a _Sumac_ +call_request+ message.
      # @return [Hash]
      def properties
        {
          'message_type' => 'call_request',
          'id' => @id,
          'object' => @object.properties,
          'method' => @method,
          'arguments' => @arguments.map(&:properties)
        }
      end

    end

  end
end
