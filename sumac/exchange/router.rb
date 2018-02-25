module Sumac
  module Exchange
    class Router
      
      def initialize(connection, socket)
        raise "argument 'connection' must be a Connection" unless connection.is_a?(Connection)
        @connection = connection
        @socket = socket
        @thread = nil
        @write_semaphore = Mutex.new
      end
      
      def get_next_exchange
        begin
          json = @socket.gets #fix space isssue
        rescue
          raise 'network error'
        end
        raise 'network error' unless json
        
        message = Message::Exchange::Dispatch.from_json(@connection, json)  
        
        #begin
        #  
        #rescue
        #  raise 'message invalid'
        #end
        
        #binding.pry
        exchange = Dispatch.from_message(@connection, message)   
        
        #begin
        #  
        #rescue
        #  raise 'exchange invalid'
        #end
        
        exchange
      end
      
      def send(exchange)
        message = exchange.to_message
        message.invert_orgin
        @write_semaphore.synchronize { @socket.puts(message.to_json) } #fix space issue
      end
      
      def process_exchange(exchange)
        case
        when exchange.kind_of?(Request::Request)
          @connection.inbound_request_manager.submit_request(exchange)
        when exchange.kind_of?(Response::Response)
          @connection.outbound_request_manager.submit_response(exchange)
        else
          raise
        end
      end
      
      def run
        @thread = Thread.new do
          loop do
            exchange = get_next_exchange
            process_exchange(exchange)
          end
        end
      end
      
    end
  end
end
