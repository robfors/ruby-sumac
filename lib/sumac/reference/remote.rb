module Sumac
  module Reference
    class Remote
      
      attr_reader :exposed_id, :remote_object
      
      def initialize(orchestrator, exposed_id)
        raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
        @orchestrator = orchestrator
        raise unless exposed_id.is_a?(Integer)
        @exposed_id = exposed_id
        @remote_object = RemoteObject.new(@orchestrator, self)
      end
      
    end
  end
end
