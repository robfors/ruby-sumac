class Sumac
  module ExposedObject
    
    def self.included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
    end
    
    def self.extended(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      def inherited(base)
        base.instance_variable_set(:@__exposed_methods__, @__exposed_methods__)
      end
      
      def __exposed_methods__
        @__exposed_methods__ ||= []
      end
      
      def expose(*method_names)
        raise ArgumentError, 'at least one argument expected' if method_names.empty?
        unless method_names.each { |method_name| method_name.is_a?(Symbol) || method_name.is_a?(String) }
          raise 'only symbols or strings expected'  
        end
        @__exposed_methods__ ||= []
        @__exposed_methods__.concat(method_names.map(&:to_s))
      end
      
    end
    
    module InstanceMethods
      
      def __exposed_methods__
        @__exposed_methods__ ||= []
        @__exposed_methods__ + self.class.__exposed_methods__
      end
      
      def expose(*method_names)
        raise ArgumentError, 'at least one argument expected' if method_names.empty?
        unless method_names.each { |method_name| method_name.is_a?(Symbol) || method_name.is_a?(String) }
          raise 'only symbols or strings expected'  
        end
        @__exposed_methods__ ||= []
        @__exposed_methods__.concat(method_names.map(&:to_s))
      end
      
    end
    
  end
end
