module Sumac

  # Raised by the remote endpoint when trying to call a method that does not exist or has not been exposed.
  class UnexposedMethodError < Error

    def initialize(message = 'method is not defined or has not been exposed')
      super
    end

  end

end
