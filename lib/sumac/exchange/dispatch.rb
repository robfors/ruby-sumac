module Sumac
  class Exchange
    module Dispatch
    
      def self.from_message(connection, message)
        case
        when message.is_a?(Message::Exchange::CompatibilityHandshake)
          CompatibilityHandshake.from_message(connection, message)
        when message.is_a?(Message::Exchange::EntryHandshake)
          EntryHandshake.from_message(connection, message)
        when message.is_a?(Message::Exchange::CallRequest)
          CallRequest.from_message(connection, message)
        when message.is_a?(Message::Exchange::CallResponse)
          CallResponse.from_message(connection, message)
        else
          raise
        end
      end
      
    end
  end
end
