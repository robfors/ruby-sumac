module Sumac
  class Calls

    # Manages calls originating from this endpoint.
    # Keeps track of ongoing calls such that:
    # * a response can be routed to them
    # * they can be canceled if the connection is prematurely closed
    # * the connection can be set to the correct state when it knows all calls have completed
    # @api private
    class LocalCalls

      # Build a new {LocalCalls} manager.
      # @param connection [Connection] calls are to be made on
      # @return [LocalCalls]
      def initialize(connection)
        @connection = connection
        @calls = {}
        @id_allocator = IDAllocator.new
      end
      
      # Check of any ongoing calls exist.
      # @return [Boolean]
      def any?
        @calls.any?
      end

      # Cancel all ongoing calls.
      # @return [void]
      def cancel
        @calls.values.each do |call|
          call.cancel
          finished(call)
        end
      end

      # Builds a new {LocalCall} and sends a message to the remote endpoint.
      # @param request [Hash] call parameters: object, method, arguments
      # @raise [UnexposedObjectError] if an object is an invalid
      # @raise [StaleObjectError] if an object has been forgoten by this endpoint
      #   (may not be forgoten by the remote endpoint yet)
      # @return [LocalCall]
      def process_request(request)
        ([request[:object]] + request[:arguments]).each { |object| @connection.objects.ensure_sendable(object) }
        id = @id_allocator.allocate
        call = LocalCall.new(@connection, id: id, object: request[:object], method: request[:method], arguments: request[:arguments])
        @calls[id] = call
        call.send
        call.return_future
      end

      # Processes a {Messages::CallResponse} message.
      # Called when a relevant message has been received by the messenger.
      # @param message [Messages::CallResponse]
      # @raise [ProtocolError] if an ongoing call was not found with the id received
      # @return [void]
      def process_response_message(message)
        call = @calls[message.id]
        raise ProtocolError unless call
        call.process_response_message(message)
        finished(call)
      end

      private

      # Cleans up a call that has finished.
      # Removes it from the list of calls.
      # Free its id so a new call can use it.
      # @return [void]
      def finished(call)
        @calls.delete(call.id)
        @id_allocator.free(call.id)
      end

    end

  end
end
