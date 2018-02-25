module Sumac
  class Receiver
  
    def initialize(orchestrator)
      raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
      @orchestrator = orchestrator
      @thread = nil
      @receivers = {}
      @waiter = Waiter.new
    end
    
    def start
      raise 'already started' if @thread
      @thread = Thread.new { async_loop }
      nil
    end
    
    def finish
      @thread.join unless Thread.current == @thread
    end
    
    private
    
    def async_loop
      loop do
        begin
          json = @orchestrator.messenger.receive
        rescue Adapter::Closed, Adapter::ConnectionError
          @orchestrator.mutex.synchronize { network_error unless @orchestrator.closed? }
          break
        end
        @orchestrator.mutex.synchronize do
          begin
            exchange = Message::Exchange::Dispatch.from_json(@orchestrator, json)
            process(exchange)
          rescue MessageError
            message_error
            break
          rescue Closed
            break
          end
        end
      end
      nil
    end
    
    def process(exchange)
      case exchange
      when Message::Exchange::CompatibilityNotification, Message::Exchange::InitializationNotification
        @orchestrator.handshake.receive(exchange)
      when Message::Exchange::CallRequest
        @orchestrator.call_processor.receive(exchange)
      when Message::Exchange::CallResponse
        @orchestrator.call_dispatcher.receive(exchange)
      when Message::Exchange::ShutdownNotification
        @orchestrator.shutdown.receive(exchange)
      when Message::Exchange::ForgetNotification
        case exchange.exposed_object
        when RemoteObject
          @orchestrator.remote_references.receive(exchange)
        when ExposedObject
          @orchestrator.local_references.receive(exchange)
        else
          raise MessageError
        end
      else
        raise MessageError
      end
      nil
    end
    
    def message_error
      unless @orchestrator.closed?
        @orchestrator.close
        @orchestrator.connection.trigger(:message_error)
      end
      nil
    end
    
    def network_error
      @orchestrator.close
      @orchestrator.connection.trigger(:network_error)
      nil
    end
    
  end
end
