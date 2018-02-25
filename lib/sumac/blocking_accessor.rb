module Sumac
  class BlockingAccessor
  
    def initialize
      @mutex = Mutex.new
      @resource = ConditionVariable.new
      @value = nil
      @value_ready = false
    end
    
    def value
      @mutex.synchronize do
        @resource.wait(@mutex) unless value_ready?
        @value
      end
    end
    
    def value=(new_value)
      @mutex.synchronize do
        @value = new_value
        @value_ready = true
        @resource.broadcast
        @value
      end
    end
    
    def value_ready?
      @value_ready
    end
    
  end
end
