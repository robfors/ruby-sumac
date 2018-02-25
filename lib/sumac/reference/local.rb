module Sumac
  module Reference
    class Local
    
      attr_reader :exposed_id, :exposed_object
      
      def initialize(orchestrator, exposed_id, exposed_object)
        raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
        @orchestrator = orchestrator
        raise unless exposed_id.is_a?(Integer)
        @exposed_id = exposed_id
        @exposed_object = exposed_object
      end
      
    end
  end
end
