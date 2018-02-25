module Sumac
  module GlobalIDManager
  
    @semaphore = Mutex.new
    @last_global_id = 0
      
    def self.generate_global_id
      semaphore.synchronize do
        @last_global_id += 1
        @last_global_id
      end
    end
    
  end
end
