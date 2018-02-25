module Sumac
  module Exchange
    module Response
      class Handshake < Response
      
        def initialize(connection)
          super
          @status = nil
        end
        
        def parse_message(message)
          raise unless message.is_a?(Message::Exchange::HandshakeResponse)
          raise unless message.id.is_a?(Integer)
          @id = message.id
          raise unless message.status.is_a?(String)
          @status = message.status
          nil
        end
        
        def status
          raise unless setup?
          @status
        end
        
        def status=(new_status)
          raise unless new_status.is_a?(String)
          @status = new_status
        end
        
        def to_message
          raise unless setup?
          message = Message::Exchange::HandshakeResponse.new(@connection)
          message.id = @id
          message.status = @status
          message
        end
        
        private
        
        def setup?
          super && @status != nil
        end
      
      end
    end
  end
end
