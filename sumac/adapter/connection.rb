require 'celluloid/io'

module Sumac
  module Adapter
    class Connection
      include Celluloid
      include Eventable
      
      def initialize(socket)
        @socket = Socket.new(socket)
        @buffer = ""
      end
      
      def run
        @socket.on(:data_received) {|data| data_received(data) }
        @socket.async.run
      end
      
      def data_received(data)
        @buffer += data
        loop do
          if @buffer[/\n/]
            messages = @buffer.split("\n")
            message = messages.shift
            @buffer = messages.join("\n")
            trigger(:message_received, message)
          else
            break
          end
        end
      end
      
    end
  end
end
