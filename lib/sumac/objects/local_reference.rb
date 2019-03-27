module Sumac
  class Objects

    # Points to a {LocalObject} that is known by the remote endpoint via an id.
    # @api private
    class LocalReference < Reference

      # Create a new {LocalReference}.
      # @param connection [Connection] that it will belongs to
      # @return [LocalReference]
      def initialize(connection, id: , object: , tentative: false)
        super(connection, id: id, tentative: tentative)
        @object = object
        LocalObject.set_reference(@connection.object_request_broker, @object, self)
      end

      # Mark object as no longer sendable.
      # @return [void]
      def no_longer_sendable
        # As we are no longer allowed to sent the {LocalObject} with this reference we will
        # remove this reference from the {LocalObject}. If the local application tries to send the
        # {LocalObject} in the future a new reference will be created.
        LocalObject.clear_reference(@connection.object_request_broker, @object)
      end

      # Gets the origin of the object.
      # @return [Symbol]
      def origin
        :local
      end

    end
  end
end
