module Sumac
  module ExposedObject
  
  
    def __global_sumac_id__
      @__global_sumac_id__ ||= GlobalIDAllocator.allocate
    end
    
    
  end
end
