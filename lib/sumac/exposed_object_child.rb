class Sumac
  module ExposedObjectChild
    
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
        base.instance_variable_set(:@__parent_accessor__, @__parent_accessor__)
        base.instance_variable_set(:@__key_accessor__, @__key_accessor__)
      end
      
      attr_reader :__parent_accessor__, :__key_accessor__
      
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
      
      def parent_accessor(method_name = nil)
        unless method_name.is_a?(Symbol) || method_name.is_a?(String)
          raise ArgumentError, "'parent_accessor' expects a method name as a string for symbol"
        end
        @__parent_accessor__ = method_name.to_s
      end
      
      def key_accessor(method_name = nil)
        unless method_name.is_a?(Symbol) || method_name.is_a?(String)
          raise ArgumentError, "'parent_accessor' expects a method name as a string for symbol"
        end
        @__key_accessor__ = method_name.to_s
      end
      
    end
    
    module IncludedInstanceMethods
      
      def __exposed_methods__
        @__exposed_methods__ ||= []
        @__exposed_methods__ + self.class.__exposed_methods__
      end
      
      def __parent__
        raise 'parent_accessor not defined' unless __parent_accessor__
        __send__(__parent_accessor__)
      end
      
      def __parent_accessor__
        @__parent_accessor__ || self.class.__parent_accessor__
      end
      
      def __key__
        raise 'key_accessor not defined' unless __key_accessor__
        __send__(__key_accessor__)
      end
      
      def __key_accessor__
        @__key_accessor__ || self.class.__key_accessor__
      end
      
      def __sumac_exposed_object__
      end
      
      def expose(*method_names)
        raise ArgumentError, 'at least one argument expected' if method_names.empty?
        unless method_names.each { |method_name| method_name.is_a?(Symbol) || method_name.is_a?(String) }
          raise 'only symbols or strings expected'  
        end
        @__exposed_methods__ ||= []
        @__exposed_methods__.concat(method_names.map(&:to_s))
      end
      
      def parent_accessor(method_name = nil)
        unless method_name.is_a?(Symbol) || method_name.is_a?(String)
          raise ArgumentError, "'parent_accessor' expects a method name as a string for symbol"
        end
        @__parent_accessor__ = method_name.to_s
      end
      
      def key_accessor(method_name = nil)
        unless method_name.is_a?(Symbol) || method_name.is_a?(String)
          raise ArgumentError, "'parent_accessor' expects a method name as a string for symbol"
        end
        @__key_accessor__ = method_name.to_s
      end
      
    end
    
    
    module ExtendedClassMethods
      
      def inherited(base)
        base.instance_variable_set(:@__exposed_methods__, @__exposed_methods__.dup)
        base.instance_variable_set(:@__parent_accessor__, @__parent_accessor__)
        base.instance_variable_set(:@__key_accessor__, @__key_accessor__)
      end
      
      def __exposed_methods__
        @__exposed_methods__ ||= []
      end
      
      def __parent__
        raise 'parent_accessor not defined' unless @__parent_accessor__
        __send__(@__parent_accessor__)
      end
      
      def __key__
        raise 'key_accessor not defined' unless @__key_accessor__
        __send__(@__key_accessor__)
      end
      
      def __sumac_exposed_object__
      end
      
      def expose(*method_names)
        raise ArgumentError, 'at least one argument expected' if method_names.empty?
        unless method_names.each { |method_name| method_name.is_a?(Symbol) || method_name.is_a?(String) }
          raise 'only symbols or strings expected'  
        end
        @__exposed_methods__ ||= []
        @__exposed_methods__.concat(method_names.map(&:to_s))
      end
      
      def parent_accessor(method_name = nil)
        unless method_name.is_a?(Symbol) || method_name.is_a?(String)
          raise ArgumentError, "'parent_accessor' expects a method name as a string for symbol"
        end
        @__parent_accessor__ = method_name.to_s
      end
      
      def key_accessor(method_name = nil)
        unless method_name.is_a?(Symbol) || method_name.is_a?(String)
          raise ArgumentError, "'parent_accessor' expects a method name as a string for symbol"
        end
        @__key_accessor__ = method_name.to_s
      end
      
    end
    
  end
end
