require_relative "../lib/sumac.rb"

binding.pry

messenger = Sumac::Adapter::TCP.connect('localhost', 2000)

binding.pry

messenger.close
