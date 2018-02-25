class Sumac
  class Messenger
  
    def initialize(connection)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
    end
    
    def send(message)
      raise unless message.is_a?(Message::Exchange)
      raise if @connection.at?([:kill, :close])
      message.invert_orgin
      message_string = message.to_json
      begin
        @connection.messenger_adapter.send(message_string)
      rescue Adapter::ClosedError
        unless @connection.at?(:close)
          @connection.to(:kill)
        end
      end
      nil
    end
    
    def receive(message_string)
      begin
        process(message_string)
      rescue MessageError
        @connection.sumac.trigger(:protocol_error)
        unless @connection.at?(:close)
          @connection.to(:kill)
        end
      end
    end
    
    def close
      begin
        @connection.messenger_adapter.close
      rescue Adapter::ClosedError
      end
    end
    
    private
    
    def process(message_string)
      exchange = Message::Exchange.from_json(@connection, message_string)
      case exchange
      when Message::Exchange::CompatibilityNotification, Message::Exchange::InitializationNotification
        @connection.handshake.receive(exchange)
      when Message::Exchange::CallRequest
        @connection.call_processor.receive(exchange)
      when Message::Exchange::CallResponse
        @connection.call_dispatcher.receive(exchange)
      when Message::Exchange::ShutdownNotification
        @connection.shutdown.receive(exchange)
      when Message::Exchange::ForgetNotification
        reference = exchange.reference
        reference.remote_forget_request
      else
        raise MessageError
      end
      nil
    end
    
  end
end
