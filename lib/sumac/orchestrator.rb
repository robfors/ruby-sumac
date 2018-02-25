module Sumac
  class Orchestrator
    include Emittable
    
    attr_reader :mutex, :connection, :call_dispatcher, :call_processor,
      :receiver, :transmitter, :handshake, :shutdown,
      :local_references, :remote_references, :local_entry, :messenger
    
    attr_accessor :remote_entry
    
    def initialize(connection, messenger, local_entry)
      @connection = connection
      @local_entry = local_entry
      @remote_entry = nil
      @started = false
      @mutex = Mutex.new
      @handshake_waiter = Waiter.new
      @messenger = messenger
      setup
      @closed = false
    end
    
    def setup
      @receiver = Receiver.new(self)
      @call_dispatcher = CallDispatcher.new(self)
      @call_processor = CallProcessor.new(self)
      @transmitter = Transmitter.new(self)
      @handshake = Handshake.new(self)
      @shutdown = Shutdown.new(self)
      @local_references = Reference::LocalManager.new(self)
      @remote_references = Reference::RemoteManager.new(self)
      nil
    end
    
    def start
      @mutex.synchronize do
        raise if @started
        @started = true
        @handshake.initiate
        @handshake.on(:completed) { @handshake_waiter.resume }
        @receiver.start
      end
      @handshake_waiter.wait
      nil
    end
    
    #def kill
    #  close
    #end
    
    def close
      return if closed?
      @closed = true
      @messenger.close
      @mutex.unlock
      @receiver.finish
      @mutex.lock
      #@call_dispatcher.cancel_all
      #@call_processor.kill_all
      #@local_references.quietly_forget_all
      #@remote_references.quietly_forget_all
      trigger(:close_complete)
      @connection.trigger(:close)
    end
    
    def closed?
      @closed
    end
    
  end
end
