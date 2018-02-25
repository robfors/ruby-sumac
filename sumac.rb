require 'socket'
require 'pry'
require 'json'

require_relative 'core_extensions.rb'

module Sumac
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
  class Connection
    
    def initialize
      @call_number = -1
    end
    
    def new_call_number
      @call_number += 1
    end
    
    def byte_in
    end
    
    def message_out
    end
    
  end
end


module Sumac
  class Adapter
    
    def initialize
      @calls_waiting = {}
      @semaphore = Mutex.new
    end
    
    def disconnect
      #@socket.close
    end
    
    def call(hash)
      raise "Parameter missing from hash." unless hash.keys.include?(:type, :class, :id, :method)
      raise "Unkown parameter found in hash." if (hash.keys - [:type, :class, :id, :method]).any?
      semaphore.synchronize do
        @call_number += 1
        call_number = @call_number
        hash['call_number'] = call_number
        socket.puts hash.to_json
        @calls_waiting[call_number] = {thread: Thread.current}
      end
      Thread.stop
    end
    
    def run
      loop do
        json = socket.gets
        begin
          hash = JSON.parse(json)
        rescue JSON::ParserError => e  
          raise "Invalid incoming json"
        end
        
        case hash['type']
        when 'call'
          klass = Kernel.const_get(hash['class'])
          instance = klass.new(hash['id'])
          method_proc = instance.method(hash['method'])
          method_arguments = hash['arguments']
          return_value = dispatch_k2cN1SExzC(method_proc, method_arguments)
          return_hash = {type: 'return', value: return_value, call_number: hash['call_number']}
          socket.puts(return_hash.to_json)
        when 'return'
          @semaphore.synchronize do
            call = @calls_waiting[hash['call_number']]
            if call
              call[:response] = response_hash['value']
              call[:thread].wakeup
            else
              raise "call number #{hash['call_number']} for return is not valid."
            end
          end
        else
          raise "request type invalid"
        end
      end
    end
    
    #unique method name added to stack trace for later use
    def self.dispatch_k2cN1SExzC(method_proc, method_arguments)
      method_proc.call(*method_arguments)
    end
  end
  
  
  class ClientAdapter < Adapter
    def initialize(ip_address, port)
      super()
      @ip_adress = ip_adress
      @port = port
      @socket = nil
    end
  
    def connect
      @socket = TCPSocket.new(@ip_address, @port)
    end
  end
  
  
  class ServerAdapter < Adapter
    def initialize(port)
      super()
      @port = port
      @socket = nil
    end
  
    def accept
      @socket = TCPServer.new(@port)
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
