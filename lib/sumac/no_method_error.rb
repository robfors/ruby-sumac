module Sumac
  class NoMethodError < StandardError
  
    def message
      "method is undefined or has not been exposed"
    end
    
  end
end
