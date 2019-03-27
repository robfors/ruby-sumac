module Sumac
  class Calls

    # Manages calls originating from the remote endpoint.
    # Keeps track of ongoing calls such that:
    # * a killed connection can wait for them to finish
    # * the connection can be set to the correct state when it knows all calls have completed
    # @api private
    class RemoteCalls

      # Build a new {RemoteCalls} manager.
      # @param connection [Connection] calls are to be made from
      # @return [RemoteCalls]
      def initialize(connection)
        @connection = connection
        @calls = {}
      end

      # Check if any ongoing calls exist.
      # @return [Boolean]
      def any?
        @calls.any?
      end

      # Processes a {Messages::CallRequest} message.
      # Called when a relevant message has been received by the messenger.
      # @param message [Messages::CallRequest]
      # @raise [ProtocolError] if an ongoing call aready exists with the id received
      # @return [void]
      def process_request_message(message)
        raise ProtocolError if @calls[message.id]
        call = RemoteCall.new(@connection)
        call.process_request_message(message)
        @calls[message.id] = call
      end

      # Processes a the response of a remote call that has returned.
      # @param call [RemoteCall]
      # @param quiet [Boolean] suppress any message to the remote endpoint
      # @return [void]
      def process_response(call, quiet: )
        call.process_response unless quiet
        finished(call)
      end

      # Validate the received method and arguments for the call.
      # @param call [RemoteCall]
      # @return [Boolean] if request is valid (a response has not been sent)
      def validate_request(call)
        call.validate_request
      end

      private

      # Cleans up a call that has finished.
      # Removes it from the list of calls so a future call can use the same id.
      # @param call [RemoteCall]
      # @return [void]
      def finished(call)
        @calls.delete(call.id)
      end

    end

  end
end
