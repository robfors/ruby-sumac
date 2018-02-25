module Sumac
  class Connection
  
    attr_reader :exchange_router, :inbound_request_manager, :outbound_request_manager,
      :local_reference_manager, :remote_reference_manager, :local_entry, :socket, :handshake
    
    attr_accessor :remote_entry
    
    def initialize(socket, local_entry = nil)
      @socket = socket
      @local_entry = local_entry
      setup
      @remote_entry = nil
      start
    end
    
    def setup
      @exchange_router = Exchange::Router.new(self, @socket)
      @inbound_request_manager = Exchange::InboundRequestManager.new(self)
      @outbound_request_manager = Exchange::OutboundRequestManager.new(self)
      @local_reference_manager = Reference::LocalManager.new(self)
      @remote_reference_manager = Reference::RemoteManager.new(self)
      @handshake = Handshake.new(self)
    end
    
    def start
      @exchange_router.run
      @handshake.send
    end
    
    def ready?
      @handshake.complete?
    end
    
    def entry
      @handshake.wait_until_complete
      @remote_entry
    end
    
  end
end
