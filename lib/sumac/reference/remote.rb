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
        @forget_synchronizer = Synchronizer.new(@orchestrator, Message::Exchange::ForgetNotification)
        @forget_waiter = Waiter.new
      end
      
      def setup
        @forget_synchronizer.local_notification.exposed_object = @remote_object
        @forget_synchronizer.on(:synchronized) { forget_synchronized }
      end
      
      def receive(exchange)
        raise MessageError unless exchange.is_a?(Message::Exchange::ForgetNotification)
        @forget_synchronizer.receive(exchange)
        nil
      end
      
      def forget
        unless forgoten?
          @forget_synchronizer.initiate
          @orchestrator.mutex.unlock
          @forget_waiter.wait
          @orchestrator.mutex.lock
        end
      end
      
      def forgoten?
        @forget_synchronizer.synchronized?
      end
      
      private
      
      def forget_synchronized
        @forget_waiter.resume
        @orchestrator.remote_references.remove(self)
      end
      
    end
  end
end
