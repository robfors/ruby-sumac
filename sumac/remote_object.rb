module Sumac
  module RemoteObject
    
    def initialize(args)
      @connection = args[:session]
      raise 'No session specified.' unless @session
      @object_id = args[:object_id]
      @class = args[:class]
      raise 'Need to specify object_id or klass.' unless @object_id || @klass
    end

    def method_missing(method_name, *args, &block)
      @session.call({'class': @class, 'object_id': @object_id, 'method': method_name})
      #target.respond_to?(method_name) ? target.__send__(method_name, *args, &block) : super
    end
    
    def remote
      method_name = caller[0].match(/`(?<method_name>.+)'/).to_h.symbolize_keys[:method_name]
      Sumac.call({'type': 'call', 'class': self.class.to_s, 'id': self.id, 'method': method_name})
    end
    
    def remote?
      caller[2].match(/`(?<method_name>.+)'/).to_h.symbolize_keys[:method_name] == 'dispatch_k2cN1SExzC'
    end
    
  end
end
