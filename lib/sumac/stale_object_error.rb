module Sumac
  
  # Raised by the local or remote endpoint when trying to send an object that has been forgoten (at least locally).
  class StaleObjectError < Error

    def initialize(message = 'object has been forgotten, it no longer exists on the remote endpoint')
      super
    end

  end

end
