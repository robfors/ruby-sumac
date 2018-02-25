module Sumac
  class Message
    class Exchange
      class RequestResponse < Exchange
      
        def initialize(connection)
          super
          @id = nil
        end
        
        def id
          raise unless setup?
          @id
        end
        
        def id=(new_id)
          @id = new_id
        end
        
        private
        
        def setup?
          @id != nil
        end
        
      end
    end
  end
end
