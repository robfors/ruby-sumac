module Sumac
  module Messages
    module Component

      # Representes a _Sumac_ +null+ message component.
      # Translates to +nil+ in Ruby.
      # @api private
      class Null < Base

        # Build a {Null} message component.
        # @return [Null]
        def self.from_object
          new
        end

        # Build a {Null} message component from the properties of a received _Sumac_ +null+ message component.
        # @param properties [Hash] properties received from remote endpoint
        # @raise [ProtocolError] if a property is missing or unexpected for this component type
        # @return [Null]
        def self.from_properties(properties)
          raise ProtocolError unless properties.keys.length == 1
          new
        end

        # Build the object represented by the message component.
        # @return [nil]
        def object
          nil
        end

        # Returns a +Hash+ of properties that can be converted into
        # a json string to make a _Sumac_ +null+ message component.
        # @return [Hash]
        def properties
          { 'object_type' => 'null' }
        end

      end

    end
  end
end
