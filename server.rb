require 'socket'
require 'pry'
require 'json'

require_relative 'sumac.rb'

class Game
  include Sumac::DistributedObject
  
  attr_accessor :id
  
  def initialize(id)
    @id = id
  end
  
  def name
    title
  end
  
  def title
    binding.pry
    if remote?
      'remote'
    else
      'local'
    end      
  end

end

#game = Game.new(0)
#puts game.name


server = TCPServer.new(2000)
Sumac.socket = server.accept

Sumac.listen
