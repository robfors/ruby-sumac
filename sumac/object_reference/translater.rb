module Sumac
  module ObjectReference
    module Translater
    
    
      def native_to_reference(object)
        #in:
        # - RemoteObjectWrapper
        # - ExposedObject
        # - primitive object: NilClass, TrueClass, FalseClass, String, Numeric, Hash, Array (frozen to avoid unexpected behavour)
        #out:
        # - RemoteObjectReference
        # - LocalObjectReference
        # - primitive object: NilClass, TrueClass, FalseClass, String, Numeric, Hash, Array
        
        case
        when object.is_a?(RemoteObjectWrapper)
          object.__sumac_remote_object_reference__
        when object.respond_to?(:__global_sumac_id__)
          @connection.local_reference_manager.retrieve_or_create(object)
        when [NilClass, TrueClass, FalseClass, String, Numeric].any? { |klass| object.is_a?(klass) }
          object.freeze
        when object.is_a?(Array)
          object.map { |element| native_to_reference(element) }.freeze
        when object.is_a?(Hash)
          object.map { |key, value| [native_to_reference(key), native_to_reference(value)] }.to_h.freeze
        else
          raise 'not allowed to expose this object'
        end
      end
      
      
      def reference_to_native(object)
        #in:
        # - RemoteObjectReference
        # - LocalObjectReference
        # - primitive object: NilClass, TrueClass, FalseClass, String, Numeric, Hash, Array
        #out:
        # - RemoteObjectWrapper
        # - ExposedObject
        # - primitive object: NilClass, TrueClass, FalseClass, String, Numeric, Hash, Array (frozen to avoid unexpected behavour)
        
        case
        when object.is_a?(ObjectReference::Local)
          object.exposed_object
        when object.is_a?(ObjectReference::Remote)
          object.remote_object_wrapper
        when [NilClass, TrueClass, FalseClass, String, Numeric].any? { |klass| object.is_a?(klass) }
          object.freeze
        when object.is_a?(Array)
          object.map { |element| reference_to_native(element) }.freeze
        when object.is_a?(Hash)
          object.map { |key, value| [reference_to_native(key), reference_to_native(value)] }.to_h.freeze
        else
          raise 'system error. should not be here!'
        end
      end
      
      
    end
  end
end
