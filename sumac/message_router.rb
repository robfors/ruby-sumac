module Sumac
  class MessageRouter
    include Celluloid::IO
    
    
    def initialize(connection)
      @connection = connection
    end
    
    
    def get_next_message
      begin
        message_text = @connection.socket.gets #fix space isssue
      rescue
        raise 'network error'
      end
      raise 'network error' unless message_text
      
      begin
        message = Message.parse(message_text) 
      rescue
        raise 'message invalid'
      end
      
      return message
    end
    
    
    def send(message)
      @connection.socket.puts(message.to_json) #fix space issue
    end
    
    
    def process_message(message)
      new_message = @connection.request_manager.submit_inbound_message(message)
      send(new_message) if new_message
    end
    
    
    def run
      loop do
        message = get_next_message
        message.invert_orgin
        process_message(message)
      end
    end
    
    
  end
end
