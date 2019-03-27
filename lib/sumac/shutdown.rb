module Sumac

  # Supplies a helper method for {Connection}.
  # It has been separated only for SRP.
  # @api private
  class Shutdown

    # Build a new {Shutdown} helper.
    # @param connection [Connection] being assisted
    # @return [Shutdown]
    def initialize(connection)
      @connection = connection
    end

    # Build and send a shutdown message.
    # @return [void]
    def send_message
      message = Messages::Shutdown.build
      @connection.messenger.send(message)
    end

  end

end
