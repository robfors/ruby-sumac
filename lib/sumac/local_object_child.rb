#module Sumac

  # Use {LocalObjectChild} to permit sharing of nonpersistent objects with the remote endpoint.

  #
  # In addition to exposing methods every {LocalObject} can build its own child objects via a
  # specified factory function.
  # @example specify a child factory function
  #   class Page
  #     include LocalObject
  #   
  #     child_constructor :get_post
  #   
  #     expose_method :find_posts
  #   
  #     def get_post(key)
  #       Post.new(key)
  #     end
  #   
  #     #def find_posts(...)
  #     #  ...
  #     #end
  #   
  #   end
  #   
  #   class Post
  #     include LocalObject
  #   
  #     expose_method :date
  #   
  #     def initialize(key)
  #       @key = key
  #     end
  #   
  #     #def date
  #     #  ...
  #     #end
  #   
  #   end
  #
  # @example hold on to old children objects so we may not need to create them each time
  #   require 'ref'
  #   
  #   class Page
  #     include LocalObject
  #   
  #     child_accessor :get_post
  #   
  #     expose_method :posts
  #  
  #     def initialize
  #       @posts_alive = Ref::WeakValueMap.new
  #     end
  #   
  #     def get_post(key)
  #       @posts_alive[key] ||= Post.new(key)
  #     end
  #   
  #     #def find_posts(...)
  #     #  ...
  #     #end
  #   
  #   end
  #   
  #   class Post
  #     include LocalObject
  #
  #     parent_accessor :page
  #
  #     expose_method :date
  #   
  #     def initialize(key)
  #       @key = key
  #     end
  #   
  #     #def date
  #     #  ...
  #     #end
  #   
  #   end

  # {LocalObject}
  # A child factory function can be specified to build a child object for the 


  # @note for a more intuitive api for the application {Child} should be included and extended instead
  #   of {LocalObjectChild}
  # @see Expose
  #
  # Modifying preferences are protected by a global mutex, so they are safe to be done concurrently.
  #
  # This code has been built with the intention that any of the methods may be overridden by the
  # application. Private methods exists to retain all the functionality. Look into the methods
  # that start with +\_sumac\_+ if you need them.















# class Sumac
#   module ExposedObjectChild
    
#     def self.included(base)
#       base.extend(IncludedClassMethods)
#       base.include(IncludedInstanceMethods)
#     end
    
#     def self.extended(base)
#       base.extend(ExtendedClassMethods)
#     end
    
    
#     module IncludedClassMethods
    
#       def inherited(base)
#         base.instance_variable_set(:@__exposed_methods__, @__exposed_methods__.dup)
#         base.instance_variable_set(:@__parent_accessor__, @__parent_accessor__)
#         base.instance_variable_set(:@__key_accessor__, @__key_accessor__)
#       end
      
#       attr_reader :__parent_accessor__, :__key_accessor__
      
#       def __exposed_methods__
#         @__exposed_methods__ ||= []
#       end
      
#       def expose(*method_names)
#         raise ArgumentError, 'at least one argument expected' if method_names.empty?
#         unless method_names.each { |method_name| method_name.is_a?(Symbol) || method_name.is_a?(String) }
#           raise 'only symbols or strings expected'  
#         end
#         @__exposed_methods__ ||= []
#         @__exposed_methods__.concat(method_names.map(&:to_s))
#       end
      
#       def parent_accessor(method_name = nil)
#         unless method_name.is_a?(Symbol) || method_name.is_a?(String)
#           raise ArgumentError, "'parent_accessor' expects a method name as a string for symbol"
#         end
#         @__parent_accessor__ = method_name.to_s
#       end
      
#       def key_accessor(method_name = nil)
#         unless method_name.is_a?(Symbol) || method_name.is_a?(String)
#           raise ArgumentError, "'parent_accessor' expects a method name as a string for symbol"
#         end
#         @__key_accessor__ = method_name.to_s
#       end
      
#     end
    
#     module IncludedInstanceMethods
      
#       def __exposed_methods__
#         @__exposed_methods__ ||= []
#         @__exposed_methods__ + self.class.__exposed_methods__
#       end
      
#       def __parent__
#         raise 'parent_accessor not defined' unless __parent_accessor__
#         __send__(__parent_accessor__)
#       end
      
#       def __parent_accessor__
#         @__parent_accessor__ || self.class.__parent_accessor__
#       end
      
#       def __key__
#         raise 'key_accessor not defined' unless __key_accessor__
#         __send__(__key_accessor__)
#       end
      
#       def __key_accessor__
#         @__key_accessor__ || self.class.__key_accessor__
#       end
      
#       def __sumac_exposed_object__
#       end
      
#       def expose(*method_names)
#         raise ArgumentError, 'at least one argument expected' if method_names.empty?
#         unless method_names.each { |method_name| method_name.is_a?(Symbol) || method_name.is_a?(String) }
#           raise 'only symbols or strings expected'  
#         end
#         @__exposed_methods__ ||= []
#         @__exposed_methods__.concat(method_names.map(&:to_s))
#       end
      
#       def parent_accessor(method_name = nil)
#         unless method_name.is_a?(Symbol) || method_name.is_a?(String)
#           raise ArgumentError, "'parent_accessor' expects a method name as a string for symbol"
#         end
#         @__parent_accessor__ = method_name.to_s
#       end
      
#       def key_accessor(method_name = nil)
#         unless method_name.is_a?(Symbol) || method_name.is_a?(String)
#           raise ArgumentError, "'parent_accessor' expects a method name as a string for symbol"
#         end
#         @__key_accessor__ = method_name.to_s
#       end
      
#     end
    
    
#     module ExtendedClassMethods
      
#       def inherited(base)
#         base.instance_variable_set(:@__exposed_methods__, @__exposed_methods__.dup)
#         base.instance_variable_set(:@__parent_accessor__, @__parent_accessor__)
#         base.instance_variable_set(:@__key_accessor__, @__key_accessor__)
#       end
      
#       def __exposed_methods__
#         @__exposed_methods__ ||= []
#       end
      
#       def __parent__
#         raise 'parent_accessor not defined' unless @__parent_accessor__
#         __send__(@__parent_accessor__)
#       end
      
#       def __key__
#         raise 'key_accessor not defined' unless @__key_accessor__
#         __send__(@__key_accessor__)
#       end
      
#       def __sumac_exposed_object__
#       end
      
#       def expose(*method_names)
#         raise ArgumentError, 'at least one argument expected' if method_names.empty?
#         unless method_names.each { |method_name| method_name.is_a?(Symbol) || method_name.is_a?(String) }
#           raise 'only symbols or strings expected'  
#         end
#         @__exposed_methods__ ||= []
#         @__exposed_methods__.concat(method_names.map(&:to_s))
#       end
      
#       def parent_accessor(method_name = nil)
#         unless method_name.is_a?(Symbol) || method_name.is_a?(String)
#           raise ArgumentError, "'parent_accessor' expects a method name as a string for symbol"
#         end
#         @__parent_accessor__ = method_name.to_s
#       end
      
#       def key_accessor(method_name = nil)
#         unless method_name.is_a?(Symbol) || method_name.is_a?(String)
#           raise ArgumentError, "'parent_accessor' expects a method name as a string for symbol"
#         end
#         @__key_accessor__ = method_name.to_s
#       end
      
#     end
    
#   end
# end
