module Sumac
  module Reference
    class Remote
      
      attr_reader :exposed_id, :remote_object
      
      def initialize(orchestrator, exposed_id)
        raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
        @orchestrator = orchestrator
        raise unless exposed_id.is_a?(Integer)
        @exposed_id = exposed_id
        @forget_synchronizer = Synchronizer.new(@orchestrator, Message::Exchange::ForgetNotification, @exposed_id)
        @forget_synchronizer.on(:synchronized) { @orchestrator.remote_references.remove(self) }
        @remote_object = RemoteObject.new(@orchestrator, self)
      end
      
      def forget
        @forget_synchronizer.initiate unless forgoten?
      end
      
      def forgoten?
        @forget_synchronizer.initiated?
      end
      
    end
  end
end
