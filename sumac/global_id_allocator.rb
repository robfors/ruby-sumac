module Sumac
  module GlobalIDAllocator
  
  
    @id_allocator = IDAllocator.new
    
    
    def self.allocate
      @id_allocator.allocate
    end
    
    
    def self.free(id)
      @id_allocator.free(id)
    end
    
    
  end
end
