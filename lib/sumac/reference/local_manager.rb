module Sumac
  module Reference
    class LocalManager
      
      def initialize(orchestrator)
        raise "argument 'orchestrator' must be a Orchestrator" unless orchestrator.is_a?(Orchestrator)
        @orchestrator = orchestrator
        @id_allocator = IDAllocator.new
        @exposed_id_table = {}
        @native_id_table = {}
      end
      
      def retrieve(exposed_id)
        raise unless exposed_id.is_a?(Integer)
        raise Closed if @orchestrator.closed?
        reference = @exposed_id_table[exposed_id]
        reference
      end
      
      def load(exposed_object)
        raise unless exposed_object.is_a?(ExposedObject)
        raise Closed if @orchestrator.closed?
        reference = find(exposed_object) || create(exposed_object)
        reference
      end
      
      def force_forget_all
        @exposed_id_table = {}
        @native_id_table = {}
      end
      
      def remove(reference)
        @exposed_id_table.delete(reference.exposed_id)
        @native_id_table.delete(native_id(reference.exposed_object))
      end
      
      def receive(exchange)
        raise MessageError unless exchange.is_a?(Message::Exchange::ForgetNotification)
        reference = find(exchange.exposed_object)
        reference.receive(exchange)
        nil
      end
      
      private
      
      def find(exposed_object)
        reference = @native_id_table[native_id(exposed_object)]
        reference
      end
      
      def create(exposed_object)
        new_exposed_id = @id_allocator.allocate
        new_reference = Local.new(@orchestrator, new_exposed_id, exposed_object)
        @exposed_id_table[new_exposed_id] = new_reference
        @native_id_table[native_id(exposed_object)] = new_reference
        new_reference.setup
        new_reference
      end
      
      def native_id(exposed_object)
        exposed_object.__id__
      end
      
    end
  end
end
