module Sumac
  module ObjectReference
    class LocalEntry
      include Translater
      
      
      def self.retrieve(connection)
        local_entry = new(connection)
        return local_entry.retrieve
      end
      
      
      def initialize(connection)
        @connection = connection
      end
      
      
      def retrieve
        return native_to_reference(@connection.local_entry_object)
      end
      
      
    end
  end
end
