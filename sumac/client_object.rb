module Sumac
  class ClientObject < ::BasicObject
    
    def initialize(connection, id)
      @connection = connection
      @id = id
    end
    
    def method_missing(method_name, *args, &block)
      @connection.call({'class': @class, 'object_id': @object_id, 'method': method_name})
      #target.respond_to?(method_name) ? target.__send__(method_name, *args, &block) : super
    end







  end
end


def initialize_clone(obj) # :nodoc:
  self.__setobj__(obj.__getobj__.clone)
end
def initialize_dup(obj) # :nodoc:
  self.__setobj__(obj.__getobj__.dup)
end
