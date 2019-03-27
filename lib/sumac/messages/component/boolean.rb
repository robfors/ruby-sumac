module Sumac
  module Messages
    module Component

      # Representes a _Sumac_ +boolean+ message component.
      # Translates to +true+ or +false+ in Ruby.
      # @api private
      class Boolean < Base

        # Build a {Boolean} message component from an object.
        # @param object [::Boolean]
        # @return [Boolean]
        def self.from_object(object)
          new(value: object)
        end

        # Build a {Boolean} message component from the properties of a received _Sumac_ +boolean+ message component.
        # @param properties [Hash] properties received from remote endpoint
        # @raise [ProtocolError] if a property is missing or unexpected for this component type
        # @raise [ProtocolError] if +value+ property is invalid (must be +true+ or +false+)
        # @return [Boolean]
        def self.from_properties(properties)
          raise ProtocolError unless properties.keys.length == 2
          raise ProtocolError unless properties['value'].one_of?(true, false)
          new(value: properties['value'])
        end

        # Build the object represented by the message component.
        # @return [::Boolean]
        def object
          @value
        end

        # Returns a +Hash+ of properties that can be converted into
        # a json string to make a _Sumac_ +boolean+ message component.
        # @return [Hash]
        def properties
          { 'object_type' => 'boolean', 'value' => @value }
        end

      end

    end
  end
end
