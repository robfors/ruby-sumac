module Sumac
  module Messages
    module Component

      # Representes a _Sumac_ +exposed+ message component.
      # Translates to a wrapper ({RemoteObject}) or its native object ({LocalObject}), in Ruby.
      # @api private
      class Exposed < Base

        # Build an outbound {Exposed} message component from an object.
        # @note toggles the origin, trying to get the object back from this message component
        #   will cause unexpected behaviour
        # @param object [#origin#id]
        # @return [Exposed]
        def self.from_object(object)
          case object.origin
          when :local
            origin = :remote
            id = object.id
          when :remote
            origin = :local
            id = object.id
          end
          new(origin: origin, id: id)
        end

        # Build an inbound {Exposed} message component from the properties of a received _Sumac_ +exposed+ message component.
        # @param properties [Hash] properties received from remote endpoint
        # @raise [ProtocolError] if a property is missing or unexpected for this component type
        # @raise [ProtocolError] if +origin+ property is invalid (must be +'local'+ or +'remote'+)
        # @raise [ProtocolError] if +id+ property is invalid (must be a positive +::Integer+)
        # @return [Exposed]
        def self.from_properties(properties)
          raise ProtocolError unless properties.keys.length == 3
          raise ProtocolError unless properties['origin'].one_of?('local', 'remote')
          origin = properties['origin'].to_sym
          raise ProtocolError unless ID.valid?(properties['id'])
          id = properties['id']
          new(origin: origin, id: id)
        end

        # Gets the id of the exposed object.
        # @return [Integer]
        attr_reader :id

        # Get reference represented in the message component.
        # Other parts of the code base will use these objects without caring about its type.
        # They will simply respond to +#id+ and +#origin+.
        # @return [Component::Exposed]
        def object
          self
        end

        # Gets the origin of the exposed object.
        # @return [String] will be +'local'+ or +'remote'+
        attr_reader :origin

        # Returns a +Hash+ of properties that can be converted into
        # a json string to make a _Sumac_ +exposed+ message component.
        # @return [Hash]
        def properties
          { 'object_type' => 'exposed', 'origin' => @origin.to_s, 'id' => @id }
        end

      end

    end
  end
end
