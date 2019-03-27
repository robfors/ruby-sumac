module Sumac
  module Messages
    module Component

      # Representes a _Sumac_ +integer+ message component.
      # Translates to an +::Integer+ in Ruby.
      # @api private
      class Integer < Base

        # Build a {Integer} message component from an object.
        # @param object [::Integer]
        # @return [Integer]
        def self.from_object(object)
          new(value: object)
        end

        # Build a {Integer} message component from the properties of a received _Sumac_ +integer+ message component.
        # @param properties [Hash] properties received from remote endpoint
        # @raise [ProtocolError] if a property is missing or unexpected for this component type
        # @raise [ProtocolError] if +value+ property is invalid (must be +::Integer+)
        # @return [Integer]
        def self.from_properties(properties)
          raise ProtocolError unless properties.keys.length == 2
          raise ProtocolError unless properties['value'].is_a?(::Integer)
          value = properties['value']
          new(value: value)
        end

        # Build the object represented by the message component.
        # @return [::Integer]
        def object
          @value
        end

        # Returns a +Hash+ of properties that can be converted into
        # a json string to make a _Sumac_ +integer+ message component.
        # @return [Hash]
        def properties
          { 'object_type' => 'integer', 'value' => @value }
        end

      end

    end
  end
end
