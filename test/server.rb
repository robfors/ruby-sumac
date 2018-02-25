require_relative "../lib/sumac.rb"

class Entry
  include Sumac::ExposedObject
  
  attr_accessor :value
  
  expose :test, :value, :value=, :new_user, :games
  
  def test
    #sleep 5
    #sleep(rand)
    55
  end
  
  def new_user(username)
    User.new(username)
  end
  
  def games
    Game.new
    #@games ||= [Game.new, Game.new]
  end
  
end


class User
  include Sumac::ExposedObject
  
  attr_accessor :username
  
  expose :username
  
  def initialize(username)
    @username = username
    @test = "test" * 1_000_000
  end
  
  def tt(a, b)
    {'a' => a, 'b' => b}
  end
  
end


class Game
  #include Sumac::ExposedObject
  
  def name
    'cool_game'
  end
  
end

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


waiter = Waiter.new

server = Sumac::Adapter::TCP.listen(2001)
loop do
  messenger = server.accept
  connection = Sumac.start(messenger, Entry.new)
  
  connection.on(:network_error) { puts "***NETWORK_ERROR***" }
  connection.on(:shutdown) { puts "***SHUTDOWN***" }
  connection.on(:close) { messenger.close; puts "***CLOSE***"}#; waiter.resume }
end

binding.pry
waiter.wait
