module Sumac
  module Messages
    module Component

      # Representes a _Sumac_ +array+ message component.
      # Translates to an +::Array+ in Ruby.
      # @api private
      class Array < Base

        # Build an {Array} message component from an object.
        # @param object [::Array<::Array,::Boolean,::Exception,::Float,Hash,::Integer,nil,#origin#id,::String>]
        # @return [Array]
        def self.from_object(object)
          elements = object.map { |element| Component.from_object(element) }
          new(elements: elements)
        end

        # Build an {Array} message component from the properties of a received _Sumac_ +array+ message component.
        # @param properties [Hash] properties received from remote endpoint
        # @param depth [Integer] object nesting depth of the {Array}, (not it's elements)
        # @raise [ProtocolError] if a property is missing or unexpected for this component type
        # @raise [ProtocolError] if the +elements+ property is invalid (must be an +::Array+)
        # @raise [ProtocolError] if one of the +elements+ components is invalid
        # @return [Array]
        def self.from_properties(properties, depth)
          raise ProtocolError unless properties.keys.length == 2
          raise ProtocolError unless properties['elements'].is_a?(::Array)
          elements = properties['elements'].map do |element_properties|
            Component.from_properties(element_properties, depth + 1)
          end
          new(elements: elements)
        end

        # Build the object represented by the message component.
        # @return [Array<::Array,::Boolean,::Exception,Component::Exposed,::Float,Hash,::Integer,nil,::String>]
        def object
          @elements.map { |element| element.object }
        end

        # Returns a +Hash+ of properties that can be converted into
        # a json string to make a _Sumac_ +array+ message component.
        # @return [Hash]
        def properties
          { 'object_type' => 'array', 'elements' => @elements.map(&:properties) }
        end

      end

    end
  end
end
