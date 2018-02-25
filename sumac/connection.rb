module Sumac
  class Connection
  
  
    attr_reader :message_manager, :inbound_request_manager,
      :outbound_request_manager, :local_reference_manager, :remote_reference_manager
    
    
    def initialize(socket, local_entry_object = nil)
      @socket = socket
      @message_manager = MessageManager.new(self)
      @inbound_request_manager = InboundRequestManager.new(self)
      @outbound_request_manager = OutboundRequestManager.new(self)
      @local_reference_manager = LocalReferenceManager.new(self)
      @local_reference_manager.assign(local_entry_object, 0)
      @remote_reference_manager = RemoteReferenceManager.new(self)
      @remote_entry_wrapper = @remote_reference_manager.create(0).remote_object_wrapper
    end
    
    
    def entry
      @remote_entry_wrapper
    end
    
    
  end
end
