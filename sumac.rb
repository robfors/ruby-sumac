require 'socket'
require 'pry'
require 'json'

require_relative 'core_extensions.rb'

module Sumac
  
  @call_number = -1
  
  def self.socket
    raise "No socket assigned." unless @socket
    @socket
  end
  
  def self.socket=(new_socket)
    @socket = new_socket
  end
  
  def self.call(hash)
    @call_number += 1
    call_number = @call_number
    hash['call_number'] = call_number
    socket.puts hash.to_json
    
    loop do
      json = socket.gets
      raise "JSON not valid." unless JSON.validate(json)
      response_hash = JSON.parse(json)
      case response_hash['type']
      when 'call'
        klass = Kernel.const_get(response_hash['class'])
        return_value = klass.new(response_hash['id']).send(response_hash['method'], *response_hash['arguments'])
        return_hash = {type: 'return', value: return_value, call_number: response_hash['call_number']}
        socket.puts return_hash.to_json
      when 'return'
        raise "call number for return is not valid." unless response_hash['call_number'] == call_number
        return response_hash['value']
      else
        raise "response type invalid"
      end
    end
  end
  
  def self.listen
    loop do
      json = socket.gets
      raise "JSON not valid." unless JSON.validate(json)
      response_hash = JSON.parse(json)
      case response_hash['type']
      when 'call'
        klass = Kernel.const_get(response_hash['class'])
        instance = klass.new(response_hash['id'])
        method_proc = instance.method(response_hash['method'])
        method_arguments = response_hash['arguments']
        return_value = dispatch_k2cN1SExzC(method_proc, method_arguments)
        return_hash = {type: 'return', value: return_value, call_number: response_hash['call_number']}
        socket.puts(return_hash.to_json)
      when 'return'
        raise "response type 'return' not valid right now"
      else
        raise "response type invalid"
      end
    end
  end
    
  #unique method name added to stack trace for later use
  def self.dispatch_k2cN1SExzC(method_proc, method_arguments)
    method_proc.call(*method_arguments)
  end

end


module Sumac
  module DistributedObject
    
    def remote
      method_name = caller[0].match(/`(?<method_name>.+)'/).to_h.symbolize_keys[:method_name]
      Sumac.call({'type': 'call', 'class': self.class.to_s, 'id': self.id, 'method': method_name})
    end
    
    def remote?
      caller[2].match(/`(?<method_name>.+)'/).to_h.symbolize_keys[:method_name] == 'dispatch_k2cN1SExzC'
    end
  end
end

module Sumac
  class Adapter
  
    def connect
    end
    
    def disconnect
    end
    
    def call_request
    end
    
    def call_response
    end
  end
end


module Sumac
  class Remote < ::BasicObject
    #type class/instance
    #class name
    
    attr_reader :target
    
    def initialize(target)
      @target = target
    end

    def method_missing(method_name, *args, &block)
      method_name = caller[0].match(/`(?<method_name>.+)'/).to_h.symbolize_keys[:method_name]
      Sumac.call({'type': 'call', 'class': self.class.to_s, 'id': self.id, 'method': method_name})
      target.respond_to?(method_name) ? target.__send__(method_name, *args, &block) : super
    end
    
  end
end




def initialize_clone(obj) # :nodoc:
  self.__setobj__(obj.__getobj__.clone)
end
def initialize_dup(obj) # :nodoc:
  self.__setobj__(obj.__getobj__.dup)
end
