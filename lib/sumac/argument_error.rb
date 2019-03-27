module Sumac

  # Raised by the remote endpoint when a method is called with a wrong number of arguments.
  class ArgumentError < Error

    def initialize(message = 'wrong number of arguments given')
      super
    end

  end

end
