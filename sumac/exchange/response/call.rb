module Sumac
  module Exchange
    module Response
      class Call < Response
      
        def initialize(connection)
          super
          @return_value = nil
          @return_value_set = false
        end
        
        def parse_message(message)
          raise unless message.is_a?(Message::Exchange::CallResponse)
          raise unless message.id.is_a?(Integer)
          @id = message.id
          @return_value = message.return_value
          @return_value_set = true
          nil
        end
        
        def return_value
          raise unless setup?
          @return_value
        end
        
        def return_value=(new_return_value)
          @return_value = new_return_value
          @return_value_set = true
        end
        
        def to_message
          raise unless setup?
          message = Message::Exchange::CallResponse.new(@connection)
          message.id = @id
          message.return_value = @return_value
          message
        end
        
        private
        
        def setup?
          super && @return_value_set
        end
        
      end
    end
  end
end
