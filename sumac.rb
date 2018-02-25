require 'socket'
require 'pry'
require 'json'

require_relative 'core_extensions.rb'
require_relative 'sumac/eventable.rb'
require_relative 'sumac/adapter/adapter.rb'
require_relative 'sumac/adapter/server.rb'
require_relative 'sumac/adapter/connection.rb'
require_relative 'sumac/adapter/socket.rb'

module Sumac
end

=begin
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
    
    def send_call(hash)
      raise "Parameter missing from hash." unless hash.keys.include?(:type, :class, :id, :method)
      raise "Unkown parameter found in hash." if (hash.keys - [:type, :class, :id, :method]).any?
      semaphore.synchronize do
        call_number = new_call_number
        hash['call_number'] = call_number
        @adapter.write(hash.to_json)
        @calls_waiting[call_number] = {thread: Thread.current}
      end
      Thread.stop
    end
    
  end
end
=end
