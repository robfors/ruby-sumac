module Sumac
  module Adapter
    module TCP
      class Messenger
      
        def initialize(socket)
          @socket = socket
          @closed = false
        end
        
        def send(message)
          raise Closed if closed?
          begin
            @socket.puts(message)
          rescue
            close
            raise ConnectionError
          end
          nil
        end
        
        def receive
          raise Closed if closed?
          begin
            message = @socket.gets
            #binding.pry
            raise if message == nil
          rescue
            close
            raise ConnectionError
          end
          message[0..-2]
        end
        
        def closed?
          @closed
        end
        
        def close
          @socket.close rescue nil
          @closed = true
          nil
        end
        
      end
    end
  end
end
