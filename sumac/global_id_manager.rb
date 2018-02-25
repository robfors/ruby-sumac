module Sumac
  module GlobalIDManager
  
  
    @id_manager = IDManager.new
    
    
    def self.allocate
      @id_manager.allocate
    end
    
    
    def self.free(id)
      @id_manager.free(id)
    end
    
    
  end
end
