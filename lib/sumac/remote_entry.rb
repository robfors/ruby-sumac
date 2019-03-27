module Sumac

  # Manages the entry object of the remote endpoint.
  # @api private
  class RemoteEntry
    extend Forwardable
    
    # Create a new {RemoteEntry}.
    # @return [RemoteEntry]
    def initialize
      @future = QuackConcurrency::Future.new
    end

    # Wakes with a {ClosedObjectRequestBrokerError}, any current or future thead waiting for the remote entry object.
    # To be called when the broker is killed and the remote entry has not yet been set.
    # @return [void]
    def cancel
      @future.raise(ClosedObjectRequestBrokerError)
    end

    # @!method get
    #   Gets the remote entry object.
    #   @note will block until it is available or the broker has been killed
    #   @raise [ClosedObjectRequestBrokerError] if broker was killed before the entry was received
    #   @return [Array,Boolean,Exception,ExposedObject,Float,Hash,Integer,nil,String]
    #   @see QuackConcurrency::Future#get
    def_delegator :@future, :get

    # @!method set(entry_object)
    #   Sets the remote entry object and wakes any theads waiting for it.
    #   @param entry_object [Array,Boolean,Exception,ExposedObject,Float,Hash,Integer,nil,String]
    #   @return [void]
    #   @see QuackConcurrency::Future#set
    def_delegator :@future, :set

  end

end
