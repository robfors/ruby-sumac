module Sumac
  module ObjectReference
    class RemoteEntry
      include Translater
      
      
      def self.retrieve(connection)
        remote_entry = new(connection)
        return remote_entry.retrieve
      end
      
      
      def initialize(connection)
        @connection = connection
      end
      
      
      def retrieve
        response = Request::OutboundEntry.process(@connection)
        return reference_to_native(response)
      end
      
      
    end
  end
end
