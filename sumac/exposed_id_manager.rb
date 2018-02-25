module Sumac
  class ExposedIDManager
  
    def initialize
      @semaphore = Mutex.new
      @last_local_id = 2
    end
    
    def generate_local_id
      semaphore.synchronize do
        @last_local_id += 2
        @last_local_id
      end
    end

    def get_local_entry_id
      0
    end
    
    def get_remote_entry_id
      1
    end
    
    def local_id?(id)
      raise 'ID is not valid' unless id.is_a?(Integer)
      id % 2 == 0
    end
    
    def remote_id?(id)
      !local_id?(id)
    end
    
    def local_to_remote(local_id)
      raise 'Input ID is not local' unless local_id?(local_id)
      local_id + 1
    end
    
    def remote_to_local(remote_id)
      raise 'Input ID is not remote' unless remote_id?(remote_id)
      remote_id - 1
    end
    
  end
end
