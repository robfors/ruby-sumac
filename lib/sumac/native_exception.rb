module Sumac
  class NativeException < StandardError
  
    attr_reader :native_type, :native_message
    
    def initialize(native_type, native_message)
      super()
      @native_type = native_type
      @native_message = native_message
    end
    
    def message
      "#{@native_type} -> #{@native_message}"
    end
    
  end
end
