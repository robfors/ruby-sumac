module Sumac
  class Objects

    # Points to a {RemoteObject} that is known by the local endpoint via an id.
    # @api private
    class RemoteReference < Reference

      # Create a new {RemoteReference}.
      # @param connection [Connection] that it will belongs to
      # @return [RemoteReference]
      def initialize(connection, id: , tentative: false)
        super(connection, id: id, tentative: tentative)
        @object = RemoteObject.new(@connection.object_request_broker, self)
      end

      # Gets the origin of the object.
      # @return [Symbol]
      def origin
        :remote
      end

    end

  end
end
