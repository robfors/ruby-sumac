module Sumac
  module Messages
    module Component

      # Representes a _Sumac_ +float+ message component.
      # Translates to a +::Float+ in Ruby.
      # @api private
      class Float < Base

        # Build a {Float} message component from an object.
        # @param object [Numeric]
        # @return [Float]
        def self.from_object(object)
          new(value: object)
        end

        # Build a {Float} message component from the properties of a received _Sumac_ +float+ message component.
        # @param properties [Hash] properties received from remote endpoint
        # @raise [ProtocolError] if a property is missing or unexpected for this component type
        # @raise [ProtocolError] if +value+ property is invalid (must be +Numeric+)
        # @return [Float]
        def self.from_properties(properties)
          raise ProtocolError unless properties.keys.length == 2
          raise ProtocolError unless properties['value'].is_a?(::Numeric)
          value = properties['value'].to_f
          new(value: value)
        end

        # Build the object represented by the message component.
        # @return [::Float]
        def object
          @value
        end

        # Returns a +Hash+ of properties that can be converted into
        # a json string to make a _Sumac_ +float+ message component.
        # @return [Hash]
        def properties
          { 'object_type' => 'float', 'value' => @value }
        end

      end

    end
  end
end
