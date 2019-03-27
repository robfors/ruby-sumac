module Sumac
  module Messages
    module Component

      # Representes a _Sumac_ +internal_exception+ message component.
      # Translates to an exception that was raised by _Sumac_ (not by the application).
      # @api private
      class InternalException < Base

        # Gets the class was assigned to +type+.
        # @param type [::String]
        # @return [Class]
        def self.class_from_type(type)
          klass = map.assoc(type)&.last
        end

        # Build an {InternalException} message component from an object.
        # @param object [::Exception]
        # @return [InternalException]
        def self.from_object(object)
          type = type_from_class(object.class)
          if object.message == object.class.name || object.message == object.class.new.message
            message = nil
          else
            message = object.message
          end
          new(type: type, message: message)
        end

        # Build a {InternalException} message component from the properties of a received _Sumac_ +internal_exception+ message component.
        # @param properties [Hash] properties received from remote endpoint
        # @raise [ProtocolError] if a property is missing or unexpected for this component type
        # @raise [ProtocolError] if +type+ property is invalid (must be one of the values assigned to an error class)
        # @raise [ProtocolError] if a +message+ property is not valid (must be a +::String+ if it exists)
        # @return [InternalException]
        def self.from_properties(properties)
          raise ProtocolError unless properties.keys.length.between?(2, 3)
          raise ProtocolError unless properties['type'].is_a?(::String)
          klass = class_from_type(properties['type'])
          raise ProtocolError unless klass
          if properties.keys.length == 3
            raise ProtocolError unless properties['message'].is_a?(::String)
          end
          new(klass: klass, message: properties['message'])
        end

        # Returns an associative array of all the internal exception classes
        # along with their message types.
        # @return [::Array<::Array>]
        def self.map
          @map ||=
            [
              ['argument_exception', ArgumentError],
              ['unexposed_method_exception', UnexposedMethodError]
            ]
        end

        # Get the message type assigned to +klass+.
        # @return [::String]
        def self.type_from_class(klass)
          klass = map.rassoc(klass)&.first
        end

        # Build an {::Exception} for the exception specified in the message component.
        # @return [::Exception]
        def object
          if @message
            @klass.new(@message)
          else
            @klass.new
          end
        end

        # Returns a +Hash+ of properties that can be converted into
        # a json string to make a _Sumac_ +internal_exception+ message component.
        # @return [Hash]
        def properties
          properties = { 'object_type' => 'internal_exception', 'type' => @type }
          properties['message'] = @message if @message
          properties
        end

      end

    end
  end
end
