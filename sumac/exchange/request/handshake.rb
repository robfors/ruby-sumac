module Sumac
  module Exchange
    module Request
      class Handshake < Request
      
        def initialize(connection)
          super
          @entry_object = nil
          @entry_object_set = false
        end
        
        def parse_message(message)
          raise unless message.is_a?(Message::Exchange::HandshakeRequest)
          raise unless message.id.is_a?(Integer)
          @id = message.id
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
          message = Message::Exchange::HandshakeRequest.new(@connection)
          message.id = @id
          message.entry_object = @entry_object
          message
        end
        
        def send
          response = @connection.outbound_request_manager.send(self)
          response
        end
        
        def process
          raise unless setup?
          response = @connection.handshake.process_remote_request(self)
          response.id = @id
          response
        end
        
        private
        
        def setup?
          super && @entry_object_set
        end
      
      end
    end
  end
end
