module Sumac
  module Messages

    # Namespace for a collection of classes representing _Sumac_ message components.
    # @api private
    module Component

      # Build a message component from an object.
      # @note it is assumed that the necessary checks have been done to ensure that
      #   the +object+ is a sendable type and is safe to send
      # @param object [::Array,::Boolean,::Exception,::Float,Hash,::Integer,nil,#origin#id,::String>]
      # @return [Component::Base]
      def self.from_object(object)
        case
        when object.is_a?(::Array) then Array.from_object(object)
        when object.one_of?(true, false) then Boolean.from_object(object)
        when object.is_a?(::Exception) then Exception.from_object(object)
        when object.respond_to?(:origin) && object.respond_to?(:id) then Exposed.from_object(object)
        #when object.is_a?(RemoteObjectChild) || LocalObjectChild.local_object_child?(object)
        #  ExposedChild
        when object.is_a?(::Float) then Float.from_object(object)
        when object.is_a?(::Integer) then Integer.from_object(object)
        when object.is_a?(::Hash) then Map.from_object(object)
        when object == nil then Null.from_object
        when object.is_a?(::String) then String.from_object(object)
        end
      end

      # Build a message component from received properties.
      # @param properties [Hash] properties received from remote endpoint
      # @param depth [Integer] object nesting depth
      # @raise [ProtocolError] if properties can not be parsed into a valid _Suamc_ message component
      # @return [Component::Base]
      def self.from_properties(properties, depth = 1)
        raise ProtocolError unless properties.is_a?(::Hash)
        case properties['object_type']
        when 'array'
          raise ProtocolError if (depth + 1) > MAX_OBJECT_NESTING_DEPTH
          Array.from_properties(properties, depth)
        when 'boolean' then Boolean.from_properties(properties)
        when 'exception' then Exception.from_properties(properties)
        when 'exposed' then Exposed.from_properties(properties)
        #when 'exposed_child' then ExposedChild
        when 'float' then Float.from_properties(properties)
        when 'integer' then Integer.from_properties(properties)
        when 'internal_exception' then InternalException.from_properties(properties)
        when 'map'
          raise ProtocolError if (depth + 1) > MAX_OBJECT_NESTING_DEPTH
          Map.from_properties(properties, depth)
        when 'null' then Null.from_properties(properties)
        when 'string' then String.from_properties(properties)
        else raise ProtocolError
        end
      end

    end

  end
end
