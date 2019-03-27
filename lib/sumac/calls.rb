module Sumac

  # Manages all calls belonging to {Connection}.
  # @api private
  class Calls
    extend Forwardable

    # Build a new {Calls} manager.
    # @param connection [Connection] that calls are made on/from
    # @return [Calls]
    def initialize(connection)
      @connection = connection
      @local = LocalCalls.new(@connection)
      @remote = RemoteCalls.new(@connection)
    end

    # Returns if there are any ongoing calls.
    # @return [Boolean]
    def any?
      @local.any? || @remote.any?
    end

    # Cancels all ongoing local calls.
    # To be called when the connection is killed.
    # Remote calls will not be canceled as it can not be done gracefully.
    # @return [void]
    def cancel_local
      @local.cancel
    end

    # @!method process_request
    #   @see LocalCalls#process_request
    def_delegator :@local, :process_request

    # @!method process_request_message
    #   @see RemoteCalls#process_request_message
    def_delegator :@remote, :process_request_message

    # @!method process_response
    #   @see RemoteCalls#process_response
    def_delegator :@remote, :process_response

    # @!method process_response_message
    #   @see LocalCalls#process_response_message
    def_delegator :@local, :process_response_message

    # @!method validate_request
    #   @see RemoteCalls#validate_request
    def_delegator :@remote, :validate_request

  end

end
