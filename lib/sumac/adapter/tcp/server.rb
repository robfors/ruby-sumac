module Sumac
  module Adapter
    module TCP
      class Server
      
        def initialize(server)
          @server = server
          @closed = false
        end
        
        def accept
          raise Closed if closed?
          begin
            socket = @server.accept
          rescue
            raise ConnectionError
          end
          Messenger.new(socket)
        end
        
        def closed?
          @closed
        end
        
        def close
          @server.close
          @closed = true
        end
        
      end
    end
  end
end
