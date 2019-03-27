module Sumac

  # Manages objects in relation to {Connection}.
  # @api private
  class Objects
    extend Forwardable

    # Create a new {Objects} manager.
    # @param connection [Connection] that the objects should be related to
    # @return [Objects]
    def initialize(connection)
      @connection = connection
      @local_references = LocalReferences.new(@connection)
      @remote_references = RemoteReferences.new(@connection)
    end

    # Commits any references so they will be remembered.
    # Primitives are unchanged.
    # @param reference [::Array<::Array,::Boolean,::Exception,::Float,Hash,::Integer,nil,Reference,::String>]
    # @return [void]
    def accept_reference(reference)
      iterate_non_primitives(reference) do |reference|
        reference.accept
        #when child ...
      end
    end

    # Converts objects to their properties.
    # Shortcut to calling {#convert_object_to_reference} then {#convert_reference_to_properties}.
    # @param object [::Array<::Array,::Boolean,::Exception,ExposedObject,::Float,Hash,::Integer,nil,::String>]
    # @return [::Array<::Array,::Boolean,::Exception,::Float,#origin#id,Hash,::Integer,nil,::String>]
    def convert_object_to_properties(object)
      reference = convert_object_to_reference(object)
      properties = convert_reference_to_properties(reference)
    end

    # Converts objects to their references.
    # {LocalObject}s are converted to {LocalReference}s and {RemoteObject}s to {RemoteReference}s.
    # Primitives are unchanged.
    # @param object [::Array<::Array,::Boolean,::Exception,ExposedObject,::Float,Hash,::Integer,nil,::String>]
    # @param build [Boolean] build local reference if an existing one does not exist already
    # @param tentative [Boolean] allow local reference to be quietly forgotten if rejected
    # @return [::Array<::Array,::Boolean,::Exception,::Float,Hash,::Integer,nil,Reference,::String>]
    def convert_object_to_reference(object, build: true, tentative: false)
      iterate_non_primitives(object) do |object|
        case
        when exposed_local?(object) then @local_references.from_object(object, build: build, tentative: tentative)
        when exposed_remote?(object) then @remote_references.from_object(object) # must already exist
        #when child ...
        end
      end
    end

    # Converts properties to their objects.
    # Shortcut to calling {#convert_properties_to_reference} then {#convert_reference_to_object}.
    # @param properties [::Array<::Array,::Boolean,::Exception,::Float,#origin#id,Hash,::Integer,nil,::String>]
    # @raise [ProtocolError] if a local reference does not exist with received id
    # @return [::Array<::Array,::Boolean,::Exception,ExposedObject,::Float,Hash,::Integer,nil,::String>]
    def convert_properties_to_object(properties)
      reference = convert_properties_to_reference(properties)
      object = convert_reference_to_object(reference)
    end

    # Converts properties to their references.
    # Property sets with an +origin+ of +local+ are converted to {LocalReference}s and +remote+ to {RemoteReference}s.
    # Primitives are unchanged.
    # @param properties [::Array<::Array,::Boolean,::Exception,::Float,#origin#id,Hash,::Integer,nil,::String>]
    # @param build [Boolean] build remote reference if an existing one does not exist already
    # @param tentative [Boolean] allow remote reference to be quietly forgotten if rejected
    # @raise [ProtocolError] if a local reference does not exist with received id
    # @return [::Array<::Array,::Boolean,::Exception,::Float,Hash,::Integer,nil,Reference,::String>]
    def convert_properties_to_reference(properties, build: true, tentative: false)
      iterate_non_primitives(properties) do |properties|
        case properties.origin
        when :local then @local_references.from_properties(properties) # must already exist
        when :remote then @remote_references.from_properties(properties, build: build, tentative: tentative)
        #when child ...
        end
      end
    end

    # Converts references to their objects.
    # {LocalReference}s are converted to {LocalObject}s and {RemoteReference}s to {RemoteObject}s.
    # Primitives are unchanged.
    # @param reference [::Array<::Array,::Boolean,::Exception,::Float,Hash,::Integer,nil,Reference,::String>]
    # @return [::Array<::Array,::Boolean,::Exception,ExposedObject,::Float,Hash,::Integer,nil,,::String>]
    def convert_reference_to_object(reference)
      iterate_non_primitives(reference) { |reference| reference.object }
    end

    # Converts references to their properties.
    # {LocalReference}s are converted property sets with an +origin+ of +local+ and {RemoteReference}s to +remote+.
    # Primitives are unchanged.
    # @note this method only exists for symmetry
    # @param reference [::Array<::Array,::Boolean,::Exception,::Float,Hash,::Integer,nil,Reference,::String>]
    # @return [::Array<::Array,::Boolean,::Exception,::Float,#origin#id,Hash,::Integer,nil,::String>]
    def convert_reference_to_properties(reference)
      reference
    end

    # Ensure that the objects can be sent.
    # The object must be a supported primitive type or an {ExposedObject} that is not stale.
    # @param object [Array,Boolean,Exception,ExposedObject,Float,Hash,Integer,nil,String]
    # @param depth [Integer] object nesting depth
    # @raise [UnexposedObjectError] if an object is an invalid type
    # @raise [UnexposedObjectError] if object is nested too deep
    # @raise [StaleObjectError] if an object has been forgoten by this endpoint (may not be forgoten by the remote endpoint yet)
    # @return [void]
    def ensure_sendable(object, depth = 1)
      case
      when exposed_local?(object)
      when exposed_remote?(object)
        reference = convert_object_to_reference(object)
        raise StaleObjectError unless reference.sendable?
      #when object.is_a?(RemoteObjectChild) || LocalObjectChild.local_object_child?(object)
      #  ExposedChild
      when object == nil
      when object.one_of?(false, true)
      when object.is_a?(Exception)
        raise UnexposedObjectError unless object.message == nil || object.message.is_a?(String)
      when object.is_a?(Integer)
      when object.is_a?(Float)
      when object.is_a?(String)
      when object.is_a?(Array)
        raise UnexposedObjectError, 'object nesting too deep' if (depth + 1) > MAX_OBJECT_NESTING_DEPTH
        object.each { |element| ensure_sendable(element, depth + 1) }
      when object.is_a?(Hash)
        raise UnexposedObjectError, 'object nesting too deep' if (depth + 1) > MAX_OBJECT_NESTING_DEPTH
        object.to_a.flatten(1).each { |item| ensure_sendable(item, depth + 1) }
      else
        raise UnexposedObjectError
      end
    end

    # Check if object is an exposed object.
    # @param object [Object]
    # @return [Boolean]
    def exposed?(object)
      exposed_local?(object) || exposed_remote?(object)
    end

    # Check if object has been exposed by this endpoint.
    # @param object [Object]
    # @return [Boolean]
    def exposed_local?(object)
      LocalObject.local_object?(object) && !exposed_remote?(object)
    end

    # Check if object's method has been exposed, and therefore safe to call.
    # @param object [LocalObject]
    # @param method [String]
    # @return [Boolean]
    def exposed_method?(object, method)
      LocalObject.exposed_method?(object, method)
    end

    # Check if object has been exposed by the remote endpoint.
    # @param object [Object]
    # @return [Boolean]
    def exposed_remote?(object)
      RemoteObject.remote_object?(@connection.object_request_broker, object)
    end

    # Forces all objects to be forgoten.
    # All the references will be quietly set as forgoten.
    # To be called when {Connection} is closed.
    # @return [void]
    def forget
      @local_references.forget
      @remote_references.forget
    end

    # Iterate non primitive items replacing them with returned values.
    # {LocalReference}s are converted property sets with an +origin+ of +local+ and {RemoteReference}s to +remote+.
    # Primitives are unchanged.
    # @param reference [::Array<::Array,::Boolean,::Exception,ExposedObject,::Float,Hash,#origin#id,::Integer,nil,Reference,::String>]
    # @yield called for items that are not primitives
    # @yieldparam item [ExposedObject,#origin#id,Reference]
    # @yieldreturn [Object] item to replace the current item
    # @return the original item with any replacements made
    def iterate_non_primitives(item, &block)
      case
      when item == nil then item
      when item.one_of?(false, true) then item
      when item.is_a?(Array) then item.map { |element| iterate_non_primitives(element, &block) }
      when item.is_a?(Exception) then item
      when item.is_a?(Float) then item
      when item.is_a?(Hash)
        item.map{ |key, value| [iterate_non_primitives(key, &block), iterate_non_primitives(value, &block)] }.to_h
      when item.is_a?(Integer) then item
      when item.is_a?(String) then item
      else
        yield(item)
      end
    end

    # Process a request from the local application to forget an exposed object.
    # @param object [LocalObject,RemoteObject]
    # @param quiet [Boolean] suppress any message to the remote endpoint
    # @raise [UnexposedObjectError] if object is not exposed or has never been sent on this {Connection}
    # @return [void]
    def process_forget(object, quiet: )
      reference = convert_object_to_reference(object, build: false)
      raise UnexposedObjectError unless reference
      reference.local_forget_request(quiet: quiet)
    end

    # Processes a request from the remote endpoint to forget an exposed object.
    # Called when a forget message has been received by the messenger.
    # @param message [Message::Forget]
    # @param quiet [Boolean] suppress any message to the remote endpoint
    # @raise [ProtocolError] if reference does not exist with id received
    # @return [void]
    def process_forget_message(message, quiet: )
      reference = convert_properties_to_reference(message.object, build: false)
      reference.remote_forget_request(quiet: quiet)
    end

    # Returns if the object would be allowed to be received from the broker's remote endpoint.
    # Currently only implemented for checking {RemoteObject}s.
    # @param remote_object [RemoreObject]
    # @return [Boolean]
    def receivable?(remote_object)
      reference = convert_object_to_reference(remote_object, build: false)
      reference.receivable?
    end

    # Quietly forgets any references that are tentative and not in use with another call.
    # Primitives are unchanged.
    # @param reference [::Array<::Array,::Boolean,::Exception,::Float,Hash,::Integer,nil,Reference,::String>]
    # @return [void]
    def reject_reference(reference)
      iterate_non_primitives(reference) do |reference|
        reference.reject
        #when child ...
      end
    end

    # Remove a reference of an exposed object.
    # To be called when the object has been forgoten remotely as the {Connection} will no
    # longer need to retrieve it from its id.
    # @param reference [LocalReference,RemoteReference]
    # @return [void]
    def remove_reference(reference)
      case reference
      when LocalReference then @local_references.remove(reference)
      when RemoteReference then @remote_references.remove(reference)
      end
    end

    # Returns if the object would be allowed to be sent to the broker's remote endpoint.
    # Accepts any object.
    # @param object [Object]
    # @return [Boolean]
    def sendable?(object)
      begin
        ensure_sendable(object)
        true
      rescue UnexposedObjectError, StaleObjectError
        false
      end
    end

    # Returns if the object has been forgoten by both endpoints.
    # Only checks {RemoteObject}s.
    # @param remote_object [RemoreObject]
    # @return [Boolean]
    def stale?(remote_object)
      reference = convert_object_to_reference(remote_object, build: false)
      reference.stale?
    end

  end

end
