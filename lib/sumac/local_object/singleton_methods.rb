module Sumac
  module LocalObject

    # Methods to put into an instance that is exposed.
    module SingletonMethods
      
      # attr_reader :__child_accessor__

      # def child_accessor(method_name = nil)
      #   unless method_name.is_a?(Symbol) || method_name.is_a?(String)
      #     raise ArgumentError, "'child_accessor' expects a method name as a string for symbol"
      #   end
      #   @__child_accessor__ = method_name.to_s
      # end

      # Expose a method on instances.
      # Can be overridden in a subclass or instance.
      # @param methods [Array<String,Symbol>] methods to expose
      # @return [void]
      def expose_method(*methods)
        _sumac_instance_expose_preferences.expose(methods)
      end
      alias_method :_sumac_expose_method, :expose_method

      # List all the exposed methods for instances.
      # Inherits preferences from all ancestors.
      # @return [Array<Symbol>]
      def exposed_methods
        class_ancestors = ancestors.select { |ancestor| ancestor < LocalObject }
        preferences = class_ancestors.reverse
          .map(&:_sumac_instance_expose_preferences)
        cumulative_preferences = preferences.inject(:merge)
        cumulative_preferences.exposed
      end
      alias_method :_sumac_exposed_methods, :exposed_methods

      # Attribute accessor for exposed method preferences for instances of this class.
      # Will initialize a collection if no preferences exist yet.
      # @api private
      # @return [ExposePreferences]
      def _sumac_instance_expose_preferences
        @_sumac_instance_expose_preferences ||= ExposePreferences.new
      end

      # Unexpose a method that is currenly exposed on instances.
      # Can be overridden in a subclass or instance.
      # @param methods [Array<String,Symbol>] methods to unexpose
      # @return [void]
      def unexpose_method(*methods)
        _sumac_instance_expose_preferences.unexpose(methods)
      end
      alias_method :_sumac_unexpose_method, :unexpose_method
      
    end
  end
end
