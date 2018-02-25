module Sumac
  class Connection
  
  
    attr_reader :message_router, :request_manager,
      :local_reference_manager, :remote_reference_manager, 
      :local_entry_object, :socket
    
    
    def initialize(socket, local_entry_object = nil)
      @local_entry_object = local_entry_object
      
      @socket = socket
      @message_router = MessageRouter.new(self)
      @request_manager = RequestManager.new(self)
      @local_reference_manager = ObjectReference::LocalManager.new(self)
      @remote_reference_manager = ObjectReference::RemoteManager.new(self)
      
      @message_router.async.run
    end
    
    
    def entry
      @remote_entry_wrapper ||= ObjectReference::RemoteEntry.retrieve(self)
    end
    
    
  end
end
