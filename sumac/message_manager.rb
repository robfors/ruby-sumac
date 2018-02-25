module Sumac
  class MessageManager
    include Celluloid
    
    def initialize(connection)
      @connection = connection
      aync.run
    end
    
    def get_next_message
      @connection.socket.gets #fix space isssue
    end
    
    def send_message(object)
      raise unless object.respond_to?(:message)
      @connection.socket.puts(object.message) #fix space issue
    end
    
    def run
      loop do
        message = get_next_message
        begin
          json = JSON.parse(message)
        rescue
          raise 'system error' #return error
        end
        case json['type']
        when 'request'
          request = InboundRequest.new(@connection, message)
          InboundRequestManager.submit_request(request)
        when 'response'
          response = InboundResponse.new(@connection, message)
          OutboundRequestManager.submit_response(response)
        else
          raise 'system error' #return error
        end
      end
    end
    
  end
end
