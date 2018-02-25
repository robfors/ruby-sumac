module Sumac
  module ExposedObject
  
    def __global_sumac_id__
      @__global_sumac_id__ ||= GlobalIDManager.generate_global_id
    end
    
  end
end
