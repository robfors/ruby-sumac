module Sumac
  class SequenceNumberManager
  
    def initialize
      @semaphore = Mutex.new
      @last_sequence_number = 0
    end
    
    def generate_sequence_number
      semaphore.synchronize { @last_sequence_number += 1 }
    end
    
  end
end
