module Sumac
  class RemoteObjectWrapper < BasicObject
  
    def initialize(remote_object_reference)
      @remote_object_reference = remote_object_reference
    end
    
    def method_missing(method_name, *arguments, &block)  # blocks not working yet
      @remote_object_reference.call(method_name, arguments)
    end
    
    def __sumac_remote_object_reference__
      @remote_object_reference
    end
    
  end
end
