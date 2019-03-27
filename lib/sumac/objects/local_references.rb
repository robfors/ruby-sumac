module Sumac
  class Objects

    # Manages a collection of {LocalReference}s belonging to a connection.
    # Will also have an {IDAllocator} to keep track of the {LocalReference}s id's.
    # It will allow access to existing {LocalReference}s via their {LocalObject} or id.
    # @api private
    class LocalReferences

      # Create a new {LocalReferences}.
      # @param connection [Connection] that the references belongs to
      # @return [LocalReferences]
      def initialize(connection)
        @connection = connection
        @id_allocator = IDAllocator.new
        @id_table = {}
      end

      # Forces all references to be set as forgoten.
      # To be called before the connection is closed.
      # @return [void]
      def forget
        @id_table.values.each(&:forget)
      end

      # Get a {LocalReference} for a {LocalObject}.
      # @param object [LocalObject]
      # @param build [Boolean] build reference if an existing one does not exist already
      # @param tentative [Boolean] allow reference to be quietly forgotten if rejected
      # @return [nil,LocalReference]
      def from_object(object, build: true, tentative: false)
        existing_reference = find_for_object(object, tentative: tentative)
        if existing_reference
          existing_reference
        elsif build
          create_for_object(object, tentative: tentative)
        else
          nil
        end
      end

      # Get an existing {LocalReference} from its +id+.
      # @param properties [#id]
      # @raise [ProtocolError] if reference does not exist with received id
      # @return [LocalReference]
      def from_properties(properties)
        reference = @id_table[properties.id]
        raise ProtocolError unless reference
        # may be tentative if the call that first sent it has not finished
        reference.accept
        reference
      end

      # Remove +reference+ from the connection.
      # To be called when we are confident that both endpoints will no longer try to send this
      # reference's id.
      # Removes the +reference+'s id and returns it so another {LocalReference} may use it in the future.
      # Any future reception of the id will result in an error
      # (unless the id has been given to a new {LocalReference} at that time)
      # @param reference [LocalReference]
      # @return [void]
      def remove(reference)
        @id_table.delete(reference.id)
        @id_allocator.free(reference.id)
      end

      private

      # Create a new {LocalReference} for a {LocalObject}.
      # Allocates a new id for the {LocalReference} and inserts the {LocalReference} in the table
      # by the id so it can be found later.
      # @param object [LocalObject]
      # @param tentative [Boolean] allow reference to be quietly forgotten if rejected
      # @return [LocalReference]
      def create_for_object(object, tentative: )
        id = @id_allocator.allocate
        reference = LocalReference.new(@connection, id: id, object: object, tentative: tentative)
        @id_table[id] = reference
        reference
      end

      # Try to find an existing {LocalReference} for a {LocalObject}.
      # @param object [LocalObject]
      # @param tentative [Boolean] allow reference to be quietly forgotten if rejected
      # @return [nil,LocalReference] the {LocalReference} or +nil+ if one does not exist
      def find_for_object(object, tentative: )
        reference = LocalObject.get_reference(@connection.object_request_broker, object)
        if tentative
          reference&.tentative
        else
          reference&.accept
        end
        reference
      end

    end

  end
end
