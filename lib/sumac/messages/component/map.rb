module Sumac
  module Messages
    module Component

      # Representes a _Sumac_ +map+ message component.
      # Translates to a +Hash+ in Ruby.
      # @api private
      class Map < Base

        # Build a {Map} message component from an object.
        # @param object [Hash{::Array,::Boolean,::Exception,::Float,Hash,::Integer,nil,#origin#id,::String=>::Array,::Boolean,::Exception,::Float,Hash,::Integer,nil,#origin#id,::String}]
        # @return [Map]
        def self.from_object(object)
          pairs = object.map do |key, value|
            [Component.from_object(key), Component.from_object(value)]
          end.to_h
          new(pairs: pairs)
        end

        # Build a {Map} message component from the properties of a received _Sumac_ +map+ message component.
        # @param properties [Hash] properties received from remote endpoint
        # @param depth [Integer] object nesting depth of the {Map}, (not its elements)
        # @raise [ProtocolError] if a property is missing or unexpected for this component type
        # @raise [ProtocolError] if +pairs+ property is invalid (must be an +::Array+)
        # @raise [ProtocolError] if one of the elements in the +pairs+ property have
        #   invalid keys (must have +'key'+ and +'value'+)
        # @raise [ProtocolError] if +pairs+ have duplicate key
        # @raise [ProtocolError] if one of the +pairs+ components are invalid
        # @return [Map]
        def self.from_properties(properties, depth)
          raise ProtocolError unless properties.keys.length == 2
          raise ProtocolError unless properties['pairs'].is_a?(::Array)
          properties['pairs'].each do |pair|
            raise ProtocolError unless pair.is_a?(::Hash) && pair.keys == ['key', 'value']
          end
          raise ProtocolError unless properties['pairs'].map{ |pair| pair['key'] }.uniq?
          pairs = properties['pairs'].map do |pair|
              [Component.from_properties(pair['key'], depth + 1), Component.from_properties(pair['value'], depth + 1)]
          end.to_h
          new(pairs: pairs)
        end

        # Build the object represented by the message component.
        # @return [Hash{::Array,::Boolean,::Exception,::Float,Component::Exposed,Hash,::Integer,nil,::String => ::Array,::Boolean,::Exception,::Float,Component::Exposed,Hash,::Integer,nil,::String}]
        def object
          @pairs.map { |key, value| [key.object, value.object] }.to_h
        end

        # Returns a +Hash+ of properties that can be converted into
        # a json string to make a _Sumac_ +map+ message component.
        # @return [Hash]
        def properties
          pairs_properties = @pairs.map { |key, value| { 'key' => key.properties, 'value' => value.properties } }
          { 'object_type' => 'map', 'pairs' => pairs_properties }
        end

      end

    end
  end
end
