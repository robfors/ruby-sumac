module Sumac

  # Error raised during a call on the remote endpoint.
  class RemoteError < Error

    # Build a new {RemoteError}.
    # @param remote_type [String] name of the remote type or class
    # @param remote_message [String] original message
    # @return [RemoteError]
    def initialize(remote_type, remote_message)
      super()
      @remote_type = remote_type
      @remote_message = remote_message
    end

    def message
      "#{@remote_type} -> #{@remote_message}"
    end

    # Returns the original message of the error.
    # @return [String]
    attr_reader :remote_message

    # Returns the name of the original type of class of the error.
    # @return [String]
    attr_reader :remote_type

  end

end
