module Sumac
  class Exchange
    class EntryHandshake < Exchange
    
      def initialize(connection)
        super
        @entry_object = nil
        @entry_object_set = false
      end
      
      def parse_message(message)
        raise unless message.is_a?(Message::Exchange::EntryHandshake)
        @entry_object = message.entry_object
        @entry_object_set = true
        nil
      end
      
      def entry_object
        raise unless setup?
        @entry_object
      end
      
      def entry_object=(new_entry_object)
        @entry_object = new_entry_object
        @entry_object_set = true
      end
      
      def to_message
        raise unless setup?
        message = Message::Exchange::EntryHandshake.new(@connection)
        message.entry_object = @entry_object
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
        @entry_object_set
      end
      
    end
  end
end
