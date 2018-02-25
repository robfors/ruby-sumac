require 'celluloid/io'

module Sumac
  module Adapter
    class Socket
      include Celluloid::IO
      include Eventable
      
      finalizer :shutdown
      
      def initialize(socket)
        @socket = socket
      end
      
      def shutdown
        close
      end
      
      def run
        loop do
          begin
            data = @socket.readpartial(4096)
          rescue EOFError
            close
          end
          trigger(:data_received, data)
        end
      end
      
      def close
        trigger(:closed)
        @socket.close if @socket
      end
      
      def send(data)
        @socket.write(data)
      end
    
    end  
  end
end
