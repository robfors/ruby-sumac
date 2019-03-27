module Sumac

  # Raised by the local endpoint when trying to perform an action on a closed object request broker.
  class ClosedObjectRequestBrokerError < Error

    def initialize(message = 'object request broker has closed')
      super
    end

  end

end
