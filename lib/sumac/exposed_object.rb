class Sumac
  module ExposedObject
    
    def self.included(base)
      base.extend(IncludedClassMethods)
      base.include(IncludedInstanceMethods)
    end
    
    def self.extended(base)
      base.extend(ExtendedClassMethods)
    end
    
    
    module IncludedClassMethods
      
      def inherited(base)
        base.instance_variable_set(:@__exposed_methods__, @__exposed_methods__.dup)
        base.instance_variable_set(:@__child_accessor__, @__child_accessor__)
      end
      
      attr_reader :__child_accessor__
      
      def __exposed_methods__
        @__exposed_methods__ ||= []
      end
      
      def child_accessor(method_name = nil)
        unless method_name.is_a?(Symbol) || method_name.is_a?(String)
          raise ArgumentError, "'child_accessor' expects a method name as a string for symbol"
        end
        @__child_accessor__ = method_name.to_s
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
    
    
    module IncludedInstanceMethods
      
      def __child__(key)
        raise 'child_accessor not defined' unless __child_accessor__
        __send__(__child_accessor__, key)
      end
      
      def __child_accessor__
        @__child_accessor__ || self.class.__child_accessor__
      end
      
      def __exposed_methods__
        @__exposed_methods__ ||= []
        @__exposed_methods__ + self.class.__exposed_methods__
      end
      
      def __native_id__
        __id__
      end
      
      def __sumac_exposed_object__
      end
      
      def child_accessor(method_name = nil)
        unless method_name.is_a?(Symbol) || method_name.is_a?(String)
          raise ArgumentError, "'child_accessor' expects a method name as a string for symbol"
        end
        @__child_accessor__ = method_name.to_s
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
    
    
    module ExtendedClassMethods
      
      def inherited(base)
        base.instance_variable_set(:@__exposed_methods__, @__exposed_methods__.dup)
        base.instance_variable_set(:@__child_accessor__, @__child_accessor__)
      end
      
      def __child__(key)
        raise 'child_accessor not defined' unless @__child_accessor__
        __send__(@__child_accessor__, key)
      end
      
      def __exposed_methods__
        @__exposed_methods__ ||= []
      end
      
      def __native_id__
        __id__
      end
      
      def __sumac_exposed_object__
      end
      
      def child_accessor(method_name = nil)
        unless method_name.is_a?(Symbol) || method_name.is_a?(String)
          raise ArgumentError, "'child_accessor' expects a method name as a string for symbol"
        end
        @__child_accessor__ = method_name.to_s
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
