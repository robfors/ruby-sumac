module Sumac
  module Reference
    class RemoteManager
      
      def initialize(orchestrator)
        raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
        @orchestrator = orchestrator
        @exposed_id_table = {}
      end
      
      def find_or_create(exposed_id)
        raise unless exposed_id.is_a?(Integer)
        raise Closed if @orchestrator.closed?
        reference = find(exposed_id) || create(exposed_id)
      end
      
      def load(remote_object)
        raise unless remote_object.is_a?(RemoteObject)
        raise Closed if @orchestrator.closed?
        reference = remote_object.__remote_reference__
        reference
      end
      
      def quietly_forget_all
      end
      
      private
      
      def create(new_exposed_id)
        new_reference = Remote.new(@orchestrator, new_exposed_id)
        @exposed_id_table[new_exposed_id] = new_reference
        new_reference
      end
      
      def find(exposed_id)
        reference = @exposed_id_table[exposed_id]
        reference
      end
      
    end
  end
end
