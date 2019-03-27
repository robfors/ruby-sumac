module Sumac

  # Raised by the local or remote endpoints when trying to send an object that is not a supported
  # primitive or exposed.
  class UnexposedObjectError < Error

    def initialize(message = 'object has not been exposed, it can not be send to remote endpoint')
      super
    end

  end

end
