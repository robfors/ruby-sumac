module Sumac
  module Messages

    # Representes a _Sumac_ +call_response+ message.
    # @api private
    class CallResponse < Message

      # Build a new {CallResponse} message.
      # An +exception+ or +rejected_exception+ can be passed, but not at the same time.
      # A +rejected_exception+ is set when the call could not be started implying that none of the
      # object and arguments have been accepted by the remote endpoint. They should be forgotten
      # quietly on the local endpoint. It is separate from +exception+ as we don't want to confuse
      # it with a rejected exception of a sub call.
      # @param id [Integer] the id of the call
      # @param return_value [Array,Boolean,Exception,Float,Hash,Integer,nil,#origin#id,String]
      # @param exception [Exception]
      # @param rejected_exception [Exception]
      # @return [CallResponse]
      def self.build(id: , return_value: nil, exception: nil, rejected_exception: nil)
        case
        when exception
          exception = Component.from_object(exception)
        when rejected_exception
          rejected_exception = Component::InternalException.from_object(rejected_exception)
        else
          return_value = Component.from_object(return_value)
        end
        new(id: id, return_value: return_value, exception: exception, rejected_exception: rejected_exception)
      end

      # Build a {CallResponse} message from the properties of a received _Sumac_ +call_response+ message.
      # @param properties [Hash] properties received from remote endpoint
      # @raise [ProtocolError] if a property is missing or unexpected for this message type
      # @raise [ProtocolError] if +id+ property is invalid (must be an +Integer+)
      # @raise [ProtocolError] if any +return_value+ property components are invalid
      # @raise [ProtocolError] if +exception+ property is invalid
      #   (must be an {Component::Exception} or {Component::InternalException})
      # @return [CallRequest]
      def self.from_properties(properties)
        raise ProtocolError unless properties.keys.length == 3
        raise ProtocolError unless ID.valid?(properties['id'])
        id = properties['id']
        case
        when properties['return_value']
          return_value = Component.from_properties(properties['return_value'])
        when properties['exception']
          exception = Component.from_properties(properties['exception'])
          raise ProtocolError unless exception.is_a?(Component::Exception)
        when properties['rejected_exception']
          rejected_exception = Component.from_properties(properties['rejected_exception'])
          raise ProtocolError unless rejected_exception.is_a?(Component::InternalException)
        end
        new(id: id, return_value: return_value, exception: exception, rejected_exception: rejected_exception)
      end

      # Returns an exception raised from the call, if any.
      # @return [nil,Exception] +nil+ if no exception was raised
      def exception
        @exception&.object
      end

      # Returns the id of the call.
      # @return [Integer]
      attr_reader :id

      # Returns a +Hash+ of properties that can be converted into
      # a json string to make a _Sumac_ +call_response+ message.
      # @return [Hash]
      def properties
        properties = { 'message_type' => 'call_response', 'id' => @id }
        case
        when @rejected_exception
          properties['rejected_exception'] = @rejected_exception.properties
        when @exception
          properties['exception'] = @exception.properties
        else
          properties['return_value'] = @return_value.properties
        end
        properties
      end

      # Returns an exception raised before the call could be started, if any.
      # @return [nil,Exception] +nil+ if no exception was raised
      def rejected_exception
        @rejected_exception&.object
      end

      # Returns the return value returned from the call, if any.
      # @note check for an exception first
      # @return [Array,Boolean,Component::Exposed,Exception,Float,Hash,Integer,nil,String]
      def return_value
        @return_value.object
      end

    end

  end
end
