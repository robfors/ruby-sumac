module Sumac
  class Connection
    include Celluloid
    
    attr_reader :exposed_id_manager, :message_manager, :inbound_request_manager,
      :outbound_request_manager, :exposed_local_object_manager
    
    def initialize(socket, entry_object)
      @socket = socket
      @entry_object = entry_object
      @exposed_id_manager = ExposedIDManager.new
      @message_manager = MessageManager.new(self)
      @inbound_request_manager = InboundRequestManager.new(self)
      @outbound_request_manager = OutboundRequestManager.new(self)
      @exposed_local_object_manager = ExposedLocalObjectManager.new(self, entry_object)
      @remote_entry_wrapper = RemoteObjectWrapper.new(RemoteReachableObject.new(self, @exposed_id_manager.generate_remote_entry_id))
    end
    
    def entry
      @remote_entry_wrapper
    end
    
  end
end
