module Sumac
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
        raise unless new_id.is_a?(Integer)
        @id = new_id
      end
      
      private
      
      def setup?
        @id != nil
      end
      
    end
  end
end
