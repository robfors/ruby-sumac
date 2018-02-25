module Sumac
  class ObjectReference
  
    def native_to_reference(object)
      #in:
      # - RemoteObjectWrapper
      # - ExposedObject
      # - primitive object: String, Numeric, Hash, Array (frozen to avoid unexpected behavour)
      #out:
      # - RemoteObjectReference
      # - LocalObjectReference
      # - primitive object: String, Numeric, Hash, Array
      
      when
      case object.is_a?(RemoteObjectWrapper)
        object.__sumac_remote_object_reference__
      case object.respond_to?(__global_sumac_id__)
        @connection.local_reference_manager.find_or_create(object)
      case object.is_a?(String) || @object.is_a?(Numeric)
        object.freeze
      case object.is_a?(Array)
        object.map do |element|
          element.freeze
          native_to_reference(element)
        end
      case object.is_a?(Hash)
        object.map do |key, value|
          key.freeze
          value.freeze
          [key, native_to_reference(element)]
        end.to_h
      else
        raise 'not allowed to expose this object'
      end
    end
    
    def reference_to_native(object)
      #in:
      # - RemoteObjectReference
      # - LocalObjectReference
      # - primitive object: String, Numeric, Hash, Array
      #out:
      # - RemoteObjectWrapper
      # - ExposedObject
      # - primitive object: String, Numeric, Hash, Array (frozen to avoid unexpected behavour)
      
      when
      case object.is_a?(RemoteObjectReference)
        RemoteObjectWrapper.new(object)
      case object.is_a?(LocalObjectReference)
        object.exposed_object
      case object.is_a?(String) || @object.is_a?(Numeric)
        object.freeze
      case object.is_a?(Array)
        object.map { |element| reference_to_native(element) }.freeze
      case object.is_a?(Hash)
        object.map { |key, value| [key, reference_to_native(element)] }.to_h.freeze
      else
        raise 'system error. should not be here!'
      end
    end
    
  end
end
