module Sumac

  # Manages graceful (application initiated) closing of a {Connection}.
  # Also observes ungraceful closing.
  # @api private
  class Closer

    # Build a new {Closer} manager.
    # @param connection [Connection] being managed
    # @return [Closer]
    def initialize(connection)
      @connection = connection
      @complete_future = QuackConcurrency::Future.new
      @initiate_future = QuackConcurrency::Future.new
      @killed = false
    end

    # Update the observed status of {Connection}.
    # To be called by {Connection} when it has closed (may also have been killed).
    # Will wake any waiting threads that have requested to close the connection.
    # @return [void]
    def closed
      @complete_future.set
    end

    # Returns if {Connection} has closed (may also have been killed).
    def closed?
      @complete_future.complete?
    end

    # Allows an application to request to close {Connection}.
    # @return [void] 
    def enable
      @initiate_future.set
    end

    # Block until the connection, its calls and the messenger have all ended.
    # @return [void]
    def join
      @complete_future.get
    end
    
    # Update the observed status of {Connection}.
    # To be called by {Connection} after being killed.
    # @return [void]
    def killed
      @killed = true
    end

    # Returns if {Connection} has been killed.
    # @note a killed connection may still be waiting for some remote calls to finish or the messenger to close
    # @return [Boolean]
    def killed?
      @killed
    end

    # Wait until an application can submit a request to close connection.
    # @note will block until handshake has completed or connection is killed
    # @return [void]
    def wait_until_enabled
      @initiate_future.get
    end

  end

end
