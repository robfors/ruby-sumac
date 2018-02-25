module Sumac
  module ExposedObject
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      def inherited(base)
        base.instance_variable_set(:@exposed_methods, @exposed_methods)
      end
      
      def __exposed_methods__
        @exposed_methods ||= []
      end
      
      def expose(*method_names)
        unless method_names.each { |method_name| method_name.is_a?(Symbol) || method_name.is_a?(String) }
          raise 'only symbols or strings expected'  
        end
        __exposed_methods__.concat(method_names.map(&:to_s))
      end
      
    end
    
  end
end
