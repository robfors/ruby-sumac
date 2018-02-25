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
    
    def register(exchange_class, id, receiver)
      raise unless @receivers[[exchange_class, id]] == nil
      @receivers[[exchange_class, id]] = receiver
    end
    
    def deregister(exchange_class, id, receiver)
      @receivers.delete[[exchange_class, id]]
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
      id = exchange.respond_to?(:id) ? exchange.id : nil
      receiver = @receivers[[exchange.class, id]] || @receivers[[exchange.class, nil]]
      raise MessageError unless receiver
      receiver.receive(exchange)
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
