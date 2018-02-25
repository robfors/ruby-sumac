class Sumac
  class RemoteEntry
  
    def initialize
      @mutex = Mutex.new
      @condition_variable = ConditionVariable.new
      @value = nil
      @value_set = false
      @complete = false
    end
    
    def cancel
      @mutex.synchronize do
        @complete = true
        @value_set = false
        @value = false
      end
    end
    
    def get
      @mutex.synchronize do
        @condition_variable.wait(@mutex) unless complete?
        raise ClosedError unless @value_set
        @value
      end
    end
    
    def set(new_value = nil)
      @mutex.synchronize do
        @value_set = true
        @complete = true
        @value = new_value
        @condition_variable.broadcast
      end
    end
    
    def complete?
      @complete
    end
    
  end
end
