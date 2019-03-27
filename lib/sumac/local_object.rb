module Sumac

  # Use {LocalObject} to permit sharing of objects with the remote endpoint.
  #
  # Methods are exposed to the remote endpoint via specifying preferences.
  #
  # Normally you will include {LocalObject} in a class or module and call
  # +#expose_method+ to add preferences for all of its instances.
  # +#exposed_methods+ can then be called to get the list of exposed methods.
  # @example normal usage
  #   class A
  #     include LocalObject
  #   
  #     expose_method :m
  #   
  #     def m
  #       true
  #     end
  #   
  #   end
  #   
  #   a = A.new
  #   a #=> a::m can be called by remote endpoint
  #   A.exposed_methods #=> ['m']
  # @see SingletonMethods#expose_method
  # @see SingletonMethods#exposed_methods
  # If you only want to expose a method for one instance, +#expose_singleton_method+ can be used
  # to add the preference and +#exposed_singleton_methods+ to observe it.
  # @example expose a method for one instance
  #   class A
  #     include LocalObject
  #   
  #     def m
  #       true
  #     end
  #  
  #   end
  #
  #   a = A.new
  #   a.expose_singleton_method(:m)
  #   a #=> a::m can be called by remote endpoint
  #   a.exposed_singleton_methods #=> ['m']
  # @see InstanceMethods#expose_singleton_method
  # @see InstanceMethods#exposed_singleton_methods
  # 
  # In some cases you may want to only expose a singleton object to the remote endpoint.
  # Do this by extending {LocalObject}.
  # @example expose a singleton object
  #   class A
  #     extend LocalObject
  #   
  #     expose_singleton_method :m
  #   
  #     def self.m
  #       true
  #     end
  #   
  #   end
  #   
  #   A #=> A#m can be called by remote endpoint
  #   A.exposed_singleton_methods #=> ['m']
  #   a = A.new
  #   a #=> a can not be shared
  #
  # It is important to keep in mind that preferences are inherited.
  # @example preferences are inherited
  #   class A
  #     include LocalObject
  #   
  #     expose_method :m
  #   
  #   end
  #   
  #   class B < A
  #   
  #     expose_method :n
  #   
  #   end
  #
  #   b = B.new
  #   b.expose_singleton_method(:o)
  #   b.exposed_singleton_methods #=> ['m','n','o']
  #
  # In rare cases you may want to unexpose a method. It this case you can use
  # +#unexpose_method+ and +#unexpose_singleton_method+. Your preferences will
  # follow Ruby's typical inheritance priority.
  # @example unexpose a method
  #   class A
  #     include LocalObject
  #   
  #     expose_method :m
  #     expose_method :n
  #   
  #   end
  #   
  #   class B < A
  #   
  #     unexpose_method :m
  #   
  #   end
  #
  #   b = B.new
  #   b.exposed_singleton_methods #=> ['n']
  # @see SingletonMethods#unexpose_method
  # @see InstanceMethods#unexpose_singleton_method
  #
  # In addition to exposing methods every {LocalObject} can build its own child objects via a
  # specified factory function. See {LocalObjectChild} for more details.
  #
  # @note for a more intuitive api for the application {Expose} should be included and extended instead
  #   of {LocalObject}
  # @see Expose
  #
  # Modifying preferences are protected by a global mutex, so they are safe to be done concurrently.
  #
  # This code has been built with the intention that any of the methods may be overridden by the
  # application. Private methods exists to retain all the functionality. Look into the methods
  # that start with +\_sumac\_+ if you need them.
  module LocalObject

    @mutex = Mutex.new

    def self.included(base)
      base.include(ExposedObject)
      base.extend(SingletonMethods)
      base.include(InstanceMethods)
    end

    def self.extended(base)
      base.extend(InstanceMethods)
    end

    # Clear the reference for a broker.
    # When we have fogoten this object locally we are really just forgeting the id
    # that the remote endpoint knows it by. There is no need for its reference
    # anymore, so call this to remove it.
    # @note protected by mutex for safety
    # @api private
    # @param object_request_broker [ObjectRequestBroker]
    # @param object [LocalObject]
    # @return [void]
    def self.clear_reference(object_request_broker, object)
      synchronize { object._sumac_local_references.delete(object_request_broker) }
    end

    # Check if a method is exposed and safe to call for +object+.
    # @api private
    # @param object [LocalObject]
    # @param method [String]
    # @return [Boolean]
    def self.exposed_method?(object, method)
      exposed_methods(object).map(&:to_s).include?(method) && object.respond_to?(method)
    end

    # List all exposed methods for +object+.
    # Same as calling +#exposed_singleton_methods+ on +object+,
    # however this class method will still work if that method has been
    # overridden by the application.
    # @note protected by mutex for safety
    # @param object [Object]
    # @raise [UnexposedObjectError] if +object+ is not a {LocalObject}
    # @return [Array<Symbol>]
    def self.exposed_methods(object)
      synchronize do
        raise UnexposedObjectError unless local_object?(object)
        object._sumac_exposed_singleton_methods
      end
    end

    # Get the reference for a broker if one exists.
    # This object may be known by multiple remote endpoints via different id's so
    # multiple references will point to this.
    # @api private
    # @param object_request_broker [ObjectRequestBroker]
    # @param object [LocalObject]
    # @return [nil,LocalReference] reference for a broker or +nil+ if none exist
    def self.get_reference(object_request_broker, object)
      synchronize { object._sumac_local_references[object_request_broker] }
    end

    # Check if object can be a {LocalObject}.
    # @note The object could also be a {RemoteObject} simultaneously
    # Uses a private method so +#exposed_singleton_methods+ can be safely overridden.
    # @api public
    # @param object [Object]
    # @return [Boolean]
    def self.local_object?(object)
      object.respond_to?(:_sumac_exposed_singleton_methods)
    end

    # Set the reference for a given broker.
    # We will rely on this reference link when this when the application sends
    # this object to the remote endpoint, the object request broker will
    # need to see if this object already has a reference, and therefore an id that
    # the remote endpoint knows it by.
    # @note protected by mutex for safety
    # @api private
    # @param object_request_broker [ObjectRequestBroker]
    # @param object [LocalObject]
    # @param reference [LocalReference]
    # @return [void]
    def self.set_reference(object_request_broker, object, reference)
      synchronize { object._sumac_local_references[object_request_broker] = reference }
    end

    # Called to protect reference lists when being accessed concurrently.
    # @api private
    # @return [Object] value returned from the block
    def self.synchronize(&block)
      @mutex.synchronize(&block)
    end
    private_class_method :synchronize

  end

end
