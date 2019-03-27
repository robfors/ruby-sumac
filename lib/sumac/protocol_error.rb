module Sumac

  # Raised by the local endpoint when the remote endpoint has sent an invalid message.
  # Will be rescued and cause the connection to be killed.
  # @api private
  class ProtocolError < Error

    def initialize(message = 'unexpected behaviour from the remote endpoint, likely due to a faulty implementation of the Sumac protocol or the messenger is not working correctly')
      super
    end

  end

end
