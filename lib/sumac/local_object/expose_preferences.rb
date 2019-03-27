module Sumac
  module LocalObject

    # Holds a collection of expose preferences for an object.
    # @api private
    class ExposePreferences

      # Build a new {ExposePreferences} collection.
      # @return [ExposePreferences]
      def initialize
        @methods = {}
      end

      # Update preferences to expose some methods.
      # Remove any existing preference for that method so we don't end
      # up with an obsolete preference taking up space.
      # @param methods [Array<String,Symbol>]
      # @raise [::ArgumentError] if no methods have been given
      # @raise [TypeError] one of the names are not valid type (should be a +Symbol+ or +String+)
      # @return [void]
      def expose(methods)
        parse_method_names(methods)
        methods.each { |method| @methods[method] = :expose }
      end

      # List all exposed methods found in preferences.
      # @return [Array<Symbol>]
      def exposed
        @methods.map{ |method, preference| method if preference == :expose }.compact
          .map(&:to_sym)
      end

      # Returns a new {ExposePreferences} containing the preferences.
      # Duplicate preferences for the same method will be set to that of +other_preferences+.
      # @return [ExposePreferences]
      def merge(other_preferences)
        methods = @methods.merge(other_preferences.methods)
        cumulative_preferences = ExposePreferences.new
        cumulative_preferences.methods = methods
        cumulative_preferences
      end

      # Returns a list of all preferences.
      # @return [Hash{String=>Symbol}]
      attr_accessor :methods

      # Update preferences to unexpose some methods.
      # Remove any existing preference for that method so we don't end
      # up with an obsolete preference taking up space.
      # @param methods [Array<String,Symbol>]
      # @raise [::ArgumentError] if no methods have been given
      # @raise [TypeError] one of the names are not valid type (should be a +Symbol+ or +String+)
      # @return [void]
      def unexpose(methods)
        parse_method_names(methods)
        methods.each { |method| @methods[method] = :unexpose }
      end

      private

      # Parse method names.
      # Names will all be converted to +String+s.
      # @param method_names [Array<String,Symbol>]
      # @raise [::ArgumentError] if no methods have been given
      # @raise [TypeError] one of the names are not valid type (should be a +Symbol+ or +String+)
      # @return [void]
      def parse_method_names(method_names)
        raise ::ArgumentError, 'at least one method expected' if method_names.empty?
        unless method_names.all? { |method_name| method_name.is_a?(Symbol) || method_name.is_a?(String) }
          raise TypeError, 'method name should be Symbol or String'
        end
        method_names.map!(&:to_s)
      end

    end

  end
end
