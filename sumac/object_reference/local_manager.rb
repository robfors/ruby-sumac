module Sumac
  module ObjectReference
    class LocalManager
      include Celluloid
      
      
      def initialize(connection)
        @connection = connection
        @id_allocator = IDAllocator.new
        @exposed_id_table = {}
        @global_id_table = {}
      end
      
      
      def assign(exposed_object, exposed_id)
        create(exposed_object, exposed_id)
      end
      
      
      def retrieve_or_create(arg)
        if @id_allocator.valid?(arg)
          exposed_id = arg
          return retrieve(exposed_id)
        else
          exposed_object = arg
          return retrieve(exposed_object) || create(exposed_object)
        end
      end
      
      
      def retrieve(arg)
        if @id_allocator.valid?(arg)
          exposed_id = arg
          reference = @exposed_id_table[exposed_id]
          raise 'object has been forgotten' unless reference #make better exception
          return reference
        else
          exposed_object = arg
          reference = @global_id_table[exposed_object.__global_sumac_id__]
          return reference
        end
      end
      
      
      private
      
      
      def create(exposed_object, exposed_id = nil)
        if exposed_id
          new_exposed_id = @id_allocator.allocate(exposed_id)
        else
          new_exposed_id = @id_allocator.allocate
        end
        new_reference = Local.new(@connection, new_exposed_id, exposed_object)
        @exposed_id_table[new_reference.exposed_id] = new_reference
        @global_id_table[new_reference.exposed_object.__global_sumac_id__] = new_reference
        return new_reference
      end
      
      
    end
  end
end
