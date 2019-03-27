module Sumac
  module Messages

    # Representes a _Sumac_ message or message component.
    # @api private
    class Base

      # Build new message or message component.
      # Accepts properties and assigns them as instance variables.
      # @return [Base]
      def initialize(**properties)
        properties.each { |k, v| instance_variable_set("@#{k}", v) }
      end

    end

  end
end
