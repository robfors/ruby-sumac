require 'socket'
require 'pry'
require 'json'

require_relative 'sumac.rb'

class Game
  include Sumac::DistributedObject
  
  adapter :default
  
  attr_accessor :id
  
  def initialize(id)
    @id = id
  end
  
  def name
    remote
  end
  
  def title
    remote
  end

end

Sumac.socket = TCPSocket.new('localhost', 2000)

game = Game.new(0)
binding.pry
puts game.name
