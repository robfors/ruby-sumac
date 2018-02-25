module Sumac
  class Exchange
    class CompatibilityHandshake < Exchange
    
      def initialize(connection)
        super
        @protocol_version = nil
      end
      
      def parse_message(message)
        raise unless message.is_a?(Message::Exchange::CompatibilityHandshake)
        @protocol_version = message.protocol_version
        nil
      end
      
      def protocol_version
        raise unless setup?
        @protocol_version
      end
      
      def protocol_version=(new_protocol_version)
        @protocol_version = new_protocol_version
      end
      
      def to_message
        raise unless setup?
        message = Message::Exchange::CompatibilityHandshake.new(@connection)
        message.protocol_version = @protocol_version
        message
      end
      
      def send
        @connection.outbound_exchange_router.submit(self)
        nil
      end
      
      def process
        raise unless setup?
        @connection.handshake.submit_remote_exchange(self)
        nil
      end
      
      private
      
      def setup?
        @protocol_version != nil
      end
      
    end
  end
end
