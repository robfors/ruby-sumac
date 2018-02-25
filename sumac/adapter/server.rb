require 'celluloid/io'

module Sumac
  module Adapter
    class Server
      include Celluloid::IO
      include Eventable
      
      finalizer :shutdown

      def initialize(port)
        @port = port
        @socket = TCPServer.new(port)
        async.run
      end
      
      def shutdown
        @server.close if @server
      end
      
      def run
        loop do
          new_connection = Connection.new(@socket.accept)
          trigger(:new_connection, new_connection)
        end
      end
    
    end  
  end
end
