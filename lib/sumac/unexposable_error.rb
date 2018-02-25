module Sumac
  class UnexposableError < StandardError
  
    def message
      "object has not been exposed, it can not be shared"
    end
  
  end
end
