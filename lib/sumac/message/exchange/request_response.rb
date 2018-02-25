module Sumac
  class Message
    class Exchange
      class RequestResponse < Exchange
      
        def initialize(orchestrator)
          super
          @id = nil
        end
        
        def id
          raise MessageError unless setup?
          @id
        end
        
        def id=(new_id)
          raise MessageErro unless new_id.is_a?(Integer)
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
