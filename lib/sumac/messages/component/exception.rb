module Sumac
  module Messages
    module Component

      # Representes a _Sumac_ +exception+ message component.
      # Translates from an +Exception+ but to a +RemoteError+ in Ruby.
      # We don't convert it to a native error as the object would not language agnostic.
      # We would not want to raise an error in Ruby and reraise it in another language as the other
      # other language would not know what to do with it.
      # @api private
      class Exception < Base

        # Build a {Exception} message component from an object.
        # @param object [::Exception]
        # @return [Exception]
        def self.from_object(object)
          message = object.message == object.class.name ? nil : object.message
          new(klass: object.class.to_s, message: message)
        end

        # Build a {Exception} message component from the properties of a received _Sumac_ +exception+ message component.
        # @param properties [Hash] properties received from remote endpoint
        # @raise [ProtocolError] if a property is missing or unexpected for this component type
        # @raise [ProtocolError] if +class+ property is invalid (must be a +::String+)
        # @raise [ProtocolError] if a +message+ property is invalid (must be a +::String+ if it exists)
        # @return [Exception]
        def self.from_properties(properties)
          raise ProtocolError unless properties.keys.length.between?(2, 3)
          raise ProtocolError unless properties['class'].is_a?(::String)
          if properties.keys.length == 3
            raise ProtocolError unless properties['message'].is_a?(::String)
          end
          new(klass: properties['class'], message: properties['message'])
        end

        # Build a wrapper for the exception specified in the message component.
        # @return [RemoteError]
        def object
          RemoteError.new(@klass, @message)
        end

        # Returns a +Hash+ of properties that can be converted into
        # a json string to make a _Sumac_ +exception+ message component.
        # @return [Hash]
        def properties
          properties = { 'object_type' => 'exception', 'class' => @klass }
          properties['message'] = @message if @message
          properties
        end

      end

    end
  end
end
