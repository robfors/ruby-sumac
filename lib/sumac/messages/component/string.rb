module Sumac
  module Messages
    module Component

      # Representes a _Sumac_ +string+ message component.
      # Translates to a +::String+ in Ruby.
      # @api private
      class String < Base

        # Build a {String} message component from an object.
        # @param object [::String]
        # @return [String]
        def self.from_object(object)
          new(value: object)
        end

        # Build a {String} message component from the properties of a received _Sumac_ +string+ message component.
        # @param properties [Hash] properties received from remote endpoint
        # @raise [ProtocolError] if a property is missing or unexpected for this component type
        # @raise [ProtocolError] if +value+ property is invalid (must be a +::String+)
        # @return [String]
        def self.from_properties(properties)
          raise ProtocolError unless properties.keys.length == 2
          raise ProtocolError unless properties['value'].is_a?(::String)
          new(value: properties['value'])
        end

        # Build the object represented by the message component.
        # @return [::String]
        def object
          @value
        end

        # Returns a +Hash+ of properties that can be converted into
        # a json string to make a _Sumac_ +string+ message component.
        # @return [Hash]
        def properties
          { 'object_type' => 'string', 'value' => @value }
        end

      end

    end
  end
end
