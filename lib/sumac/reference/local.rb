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
        @forget_synchronizer = Synchronizer.new(@orchestrator, Message::Exchange::ForgetNotification)
      end
      
      def setup
        @forget_synchronizer.local_notification.exposed_object = @exposed_object
        @forget_synchronizer.on(:synchronized) { @orchestrator.local_references.remove(self) }
      end
      
      def receive(exchange)
        raise MessageError unless exchange.is_a?(Message::Exchange::ForgetNotification)
        @forget_synchronizer.receive(exchange)
        nil
      end
      
    end
  end
end
