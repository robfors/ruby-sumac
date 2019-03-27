module Sumac

  # Wrapper for an object that exists on the remote endpoint (also called a 'stub').
  # Calling a method (that is captured by +method_missing+) will call it on the remote endpoint.
  # They can be forgoten by the application to free up memory.
  class RemoteObject
    include ExposedObject
    extend Forwardable

    # Get the reference that points to +remote_object+.
    # Clean shortcut to {#_sumac_remote_reference}.
    # @api private
    # @param remote_object [RemoteObject]
    # @return [RemoteReference]
    def self.get_reference(remote_object)
      remote_object._sumac_remote_reference
    end

    # Check if +object+ is a {RemoteObject} for +object_request_broker+.
    # @note if the object does not belong to +object_request_broker+ it could still be a {LocalObject} for another broker
    # @api private
    # @param object_request_broker [ObjectRequestBroker]
    # @param object [Object]
    # @return [Boolean]
    def self.remote_object?(object_request_broker, object)
      object.is_a?(RemoteObject) && object._sumac_object_request_broker == object_request_broker
    end

    # Build a new {RemoteObject}.
    # @api private
    # @param object_request_broker [ObjectRequestBroker] object belongs to
    # @param reference [RemoteReference] that points to this object
    # @return [RemoteObject]
    def initialize(object_request_broker, reference)
      @object_request_broker = object_request_broker
      @reference = reference
    end

    # Make both the endpoints forget the object.
    # @note will block until the remote endpoint has confirmed the reqeust
    # @return [void]
    def forget
      @object_request_broker.forget(self)
    end

    # Get a cleaner string representing the object then the inherited +#inspect+ method.
    # @return [String]
    def inspect
      "#<Sumac::RemoteObject:#{"0x00%x" % (__id__ << 1)} id:#{@reference.id} >"
    end

    # Makes a calls to the object on the remote endpoint.
    # @note will block until the call has completed
    # @param method_name [String] method to call
    # @param arguments [Array<Array,Boolean,Exception,ExposedObject,Float,Hash,Integer,nil,String>] arguments being passed
    # @raise [ClosedObjectRequestBrokerError] if broker is closed before the request is sent or respose is received
    # @raise [UnexposedObjectError] if an object being sent is an invalid type
    # @raise [StaleObjectError] if an object being sent has been forgoten by this endpoint
    #   (may not be forgoten by the remote endpoint yet)
    # @raise [RemoteError] if an error was raised during call
    # @raise [ArgumentError,StaleObjectError,UnexposedMethodError,UnexposedObjectError]
    #   if one is raised by the remote endpoint when trying to call the method or return a value (but not during the call)
    # @return [Array,Boolean,Exception,ExposedObject,Float,Hash,Integer,nil,String] value returned from the call on remote endpoint
    def method_missing(method_name, *arguments, &block)  # TODO: blocks not working yet
      arguments << block.to_lambda if block_given?
      reqeust = {object: self, method: method_name.to_s, arguments: arguments}
      begin
        return_value = @object_request_broker.call(reqeust)
      rescue ClosedObjectRequestBrokerError
        raise StaleObjectError
      end
    end

    # Check if the object can be received (not forgoten remotely).
    # @return [Boolean]
    def receivable?
      @object_request_broker.receivable?(self)
    end

    # Check if the object can be sent (not forgoten locally).
    # @return [Boolean]
    def sendable?
      @object_request_broker.sendable?(self)
    end

    # Check if object is stale (can not be sent or can not be received).
    # Call {#receivable?} and {#sendable?} for a more detailed status.
    # @return [Boolean]
    def stale?
      @object_request_broker.stale?(self)
    end

    # Get the broker that this object belongs to.
    # @return [ObjectRequestBroker]
    def _sumac_object_request_broker
      @object_request_broker
    end
    alias_method :object_request_broker, :_sumac_object_request_broker

    # Get the remote reference that points to this object.
    # @api private
    # @return [RemoteReference]
    def _sumac_remote_reference
      @reference
    end

  end

end
