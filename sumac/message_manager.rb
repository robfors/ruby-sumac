module Sumac
  class MessageManager
    include Celluloid
    
    
    def initialize(connection)
      @connection = connection
      async.run
    end
    
    
    def get_next_message
      begin
        Message.parse(@connection.socket.gets) #fix space isssue
      rescue
        raise 'system error' #return error
      end
    end
    
    
    def submit(message)
      @connection.socket.puts(message.text) #fix space issue
    end
    
    
    def run
      loop do
        message = get_next_message
        case message.type
        when 'request'
          @connection.inbound_request_manager.submit_request(message)
        when 'response'
          @connection.outbound_request_manager.submit_response(message)
        else
          raise 'system error' #return error
        end
      end
    end
    
    
  end
end
