require 'socket'
require 'pry'
require 'json'
require 'thread'

class Waiter

  def initialize
    @queue = Queue.new
  end
  
  def resume(value = nil)
    @queue << value
  end
  
  def wait
    @queue.pop
  end
  
end

server = TCPServer.new(2000)
c_socket = TCPSocket.new('localhost', 2000)
s_socket = server.accept

waiter = Waiter.new

thread = Thread.new { s_socket.gets; waiter.resume }

waiter.wait
