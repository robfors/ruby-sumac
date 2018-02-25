class Sumac
  class Connection
    include StateMachine
    
    state :initial, initial: true
    state :compatibility_handshake
    state :initialization_handshake
    state :active
    state :initiate_shutdown
    state :shutdown
    state :kill
    state :close
    
    transition from: :initial,                  to: :compatibility_handshake
    transition from: :compatibility_handshake,  to: [:initialization_handshake, :kill]
    transition from: :initialization_handshake, to: [:active, :kill]
    transition from: :active,                   to: [:initiate_shutdown, :shutdown, :kill]
    transition from: :initiate_shutdown,        to: [:shutdown, :kill]
    transition from: :shutdown,                 to: [:close, :kill]
    transition from: :kill,                     to: :close
    
    on_transition(from: :initial, to: :compatibility_handshake) do
      @handshake.send_compatibility_notification
    end
    
    on_transition(from: :compatibility_handshake, to: :initialization_handshake) do
      @handshake.send_initialization_notification
    end
    
    on_transition(from: [:compatibility_handshake, :initialization_handshake], to: :kill) do
      @local_references.detach
      @remote_references.detach
    end
    
    on_transition(from: :active) do
      @local_references.detach
      @remote_references.detach
    end
    
    on_transition(from: :active, to: [:initiate_shutdown, :shutdown]) do
      @shutdown.send_notification
    end
    
    on_transition(from: :active, to: [:initiate_shutdown, :shutdown, :kill]) do
      @sumac.trigger(:shutdown)
    end
    
    on_transition(to: [:shutdown, :kill]) do
      @closer.try_close
    end
    
    on_transition(to: :kill) do
      @call_dispatcher.kill_all
    end
    
    on_transition(to: [:kill, :close]) do
      @remote_entry.cancel
    end
    
    on_transition(to: :close) do
      @messenger.close
      @local_references.destroy
      @remote_references.destroy
      @closer.complete
      @sumac.trigger(:close)
    end
    
    attr_reader :mutex, :sumac, :call_dispatcher, :call_processor,
      :handshake, :shutdown, :local_references, :remote_references,
      :local_entry, :messenger, :remote_entry, :scheduler,
      :closer, :messenger_adapter
    
    attr_accessor :remote_entry
    
    def initialize(sumac, duck_types: , entry: , messenger: , workers: )
      super()
      @sumac = sumac
      @local_entry = entry
      @messenger_adapter = messenger
      @remote_entry = RemoteEntry.new
      @mutex = Mutex.new
      @messenger = Messenger.new(self)
      @call_dispatcher = CallDispatcher.new(self)
      @call_processor = CallProcessor.new(self)
      @handshake = Handshake.new(self)
      @shutdown = Shutdown.new(self)
      @local_references = LocalReferences.new(self)
      @remote_references = RemoteReferences.new(self)
      @scheduler = Scheduler.new(self, workers)
      @closer = Closer.new(self)
    end
    
  end
end
