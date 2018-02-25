require 'celluloid/io'

module Sumac
  module Adapter
    class Adapter
      include Celluloid::IO
      
      def self.connect(host, port)
        Connection.new(TCPSocket.new(host, port))
      end
    
      def self.listen(port)
        Server.new(port)
      end
    
    end    
  end  
end
