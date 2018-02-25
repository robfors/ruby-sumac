module Sumac
  module Exchange
    module Dispatch
    
      def self.from_message(connection, message)
        case
        when message.is_a?(Message::Exchange::HandshakeRequest)
          Request::Handshake.from_message(connection, message)
        when message.is_a?(Message::Exchange::HandshakeResponse)
          Response::Handshake.from_message(connection, message)
        when message.is_a?(Message::Exchange::CallRequest)
          Request::Call.from_message(connection, message)
        when message.is_a?(Message::Exchange::CallResponse)
          Response::Call.from_message(connection, message)
        else
          raise
        end
      end
      
    end
  end
end
