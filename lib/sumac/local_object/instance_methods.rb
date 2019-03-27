module Sumac
  module LocalObject

    # Methods to put into a class or module when its instances are exposed.
    module InstanceMethods
      
      # def __child__(key)
      #   raise 'child_accessor not defined' unless __child_accessor__
      #   __send__(__child_accessor__, key)
      # end
      
      # def __child_accessor__
      #   @__child_accessor__ || self.class.__child_accessor__
      # end

      # def child_accessor(method_name = nil)
      #   unless method_name.is_a?(Symbol) || method_name.is_a?(String)
      #     raise ArgumentError, "'child_accessor' expects a method name as a string for symbol"
      #   end
      #   @__child_accessor__ = method_name.to_s
      # end

      # Expose a method on this instance.
      # @param methods [Array<String,Symbol>] methods to expose
      # @return [void]
      def expose_singleton_method(*methods)
        _sumac_singleton_expose_preferences.expose(methods)
      end
      alias_method :_sumac_expose_singleton_method, :expose_singleton_method

      # List all the exposed methods for this instance.
      # Inherits instance preferences from the instance's class and all the class's ancestors.
      # @note this is the method used by Sumac to determine if a method is allowed to be called
      # @return [Array<Symbol>]
      def exposed_singleton_methods
        exposing_class_ancestors = self.class.ancestors.select { |ancestor| ancestor < LocalObject }
        preferences = exposing_class_ancestors.reverse
          .map(&:_sumac_instance_expose_preferences)
        preferences << _sumac_singleton_expose_preferences
        cumulative_preferences = preferences.inject(:merge)
        cumulative_preferences.exposed
      end
      alias_method :_sumac_exposed_singleton_methods, :exposed_singleton_methods

      # Attribute accessor for references that point to this object.
      # Will initialize a collection if no references exist yet.
      # @api private
      # @return [Hash{Connection=>Objects::LocalReference}]
      def _sumac_local_references
        @_sumac_local_references ||= {}
      end

      # Attribute accessor for exposed method preferences for this instance.
      # Will initialize a collection if no preferences exist yet.
      # @api private
      # @return [ExposePreferences]
      def _sumac_singleton_expose_preferences
        @_sumac_singleton_expose_preferences ||= ExposePreferences.new
      end

      # Unexpose a method that is currenly exposed on this instance.
      # @param methods [Array<String,Symbol>] methods to unexpose
      # @return [void]
      def unexpose_singleton_method(*methods)
        _sumac_singleton_expose_preferences.unexpose(methods)
      end
      alias_method :_sumac_unexpose_singleton_method, :unexpose_singleton_method

    end
  end
end
