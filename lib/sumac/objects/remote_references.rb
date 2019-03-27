module Sumac
  class Objects

    # Manages a collection of {RemoteReference}s belonging to a connection.
    # It will allow access to existing {RemoteReference}s via their {RemoteObject} or id.
    # @api private
    class RemoteReferences

      # Create a new {RemoteReferences}.
      # @param connection [Connection] that the references belongs to
      # @return [RemoteReferences]
      def initialize(connection)
        @connection = connection
        @id_table = {}
      end

      # Forces all references to be set as forgoten.
      # To be called before the broker is closed.
      # @return [void]
      def forget
        @id_table.values.each(&:forget)
      end

      # Get an existing {RemoteReference} for a {RemoteObject}.
      # @param object [RemoteObject]
      # @return [RemoteReference]
      def from_object(object)
        reference = RemoteObject.get_reference(object)
        # we know that if a remote reference is being passed by the local application it can not
        #   be tentative so there is no need to call #accept here
        reference
      end

      # Get a {RemoteReference} from its +id+.
      # @param properties [#id]
      # @param build [Boolean] build reference if an existing one does not exist already
      # @param tentative [Boolean] allow reference to be quietly forgotten if rejected
      # @return [nil,RemoteReference]
      def from_properties(properties, build: true, tentative: false)
        id = properties.id
        existing_reference = find_for_id(id, tentative: tentative)
        if existing_reference
          existing_reference
        elsif build
          create_for_id(id, tentative: tentative)
        else
          nil
        end
      end

      # Remove +reference+ from the connection.
      # To be called when we are confident that both endpoints will no longer try to send this
      # reference's id.
      # Removes the +reference+'s id and returns it so another {RemoteReference} may use it in the future.
      # @param reference [RemoteReference]
      # @return [void]
      def remove(reference)
        @id_table.delete(reference.id)
      end

      private

      # Create a new {RemoteReference} from an +id+.
      # Inserts the {RemoteReference} in the table by its id so it can be found later.
      # @param id [Integer]
      # @param tentative [Boolean] allow reference to be quietly forgotten if rejected
      # @return [RemoteReference]
      def create_for_id(id, tentative: )
        reference = RemoteReference.new(@connection, id: id, tentative: tentative)
        @id_table[id] = reference
        reference
      end

      # Try to find an existing {RemoteReference} from its +id+.
      # @param id [Integer]
      # @param tentative [Boolean] allow reference to be quietly forgotten if rejected
      # @return [nil,RemoteReference] the {RemoteReference} or +nil+ if one does not exist
      def find_for_id(id, tentative: )
        reference = @id_table[id]
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
