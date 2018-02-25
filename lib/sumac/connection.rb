module Sumac
  class Connection
  
    attr_reader :inbound_exchange_router, :outbound_exchange_router, :inbound_exchange_manager,
      :outbound_request_manager, :local_reference_manager, :remote_reference_manager,
      :local_entry, :socket, :handshake
    
    attr_accessor :remote_entry
    
    def initialize(socket, local_entry = nil)
      @socket = socket
      @local_entry = local_entry
      setup
      @remote_entry = nil
      start
    end
    
    def setup
      @inbound_exchange_router = InboundExchangeRouter.new(self, @socket)
      @outbound_exchange_router = OutboundExchangeRouter.new(self, @socket)
      @inbound_exchange_manager = InboundExchangeManager.new(self)
      @outbound_request_manager = OutboundRequestManager.new(self)
      @local_reference_manager = Reference::LocalManager.new(self)
      @remote_reference_manager = Reference::RemoteManager.new(self)
      @handshake = Handshake.new(self)
    end
    
    def start
      @inbound_exchange_router.run
      @handshake.start
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