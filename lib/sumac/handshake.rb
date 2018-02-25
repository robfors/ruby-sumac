class Sumac
  class Handshake
    include Emittable
    
    def initialize(connection)
      raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
      @connection = connection
    end
    
    def send_compatibility_notification
      message = Message::Exchange::CompatibilityNotification.new(@connection)
      message.protocol_version = 1
      @connection.messenger.send(message)
      nil
    end
    
    def send_initialization_notification
      message = Message::Exchange::InitializationNotification.new(@connection)
      begin
        message.entry = @connection.local_entry
      rescue UnexposableObjectError
        @connection.to(:kill)
      else
        @connection.messenger.send(message)
      end
      nil
    end
    
    def receive(message)
      case message
      when Message::Exchange::CompatibilityNotification
        raise MessageError unless @connection.at?(:compatibility_handshake)
        #unless message.protocol_version == 1
        #  @connection.to(:kill)
        #end
        @connection.to(:initialization_handshake)
      when Message::Exchange::InitializationNotification
        raise MessageError unless @connection.at?(:initialization_handshake)
        @connection.to(:active)
        @connection.remote_entry.set(message.entry)
      else
        raise MessageError
      end
      nil
    end
    
  end
end
