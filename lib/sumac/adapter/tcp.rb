module Sumac
  module Adapter
    module TCP
      include Celluloid::IO
      
      def self.connect(host, port)
        socket = TCPSocket.new(host, port)
        Messenger.new(socket)
      end
      
      def self.listen(port)
        Server.new(TCPServer.new(port))
      end
      
      def self.accept(port)
        server = Server.new(TCPServer.new(port))
        socket = server.accept
        server.close
        Messenger.new(socket)
      end
      
    end
  end
end
