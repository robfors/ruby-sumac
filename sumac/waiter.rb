require 'thread'

module Sumac
  class Waiter
  
    def initialize
      @queue = Queue.new
    end
    
    def resume(value = nil)
      queue << value
    end
    
    def wait
      queue.pop
    end
    
  end
end
