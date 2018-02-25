require_relative "../lib/sumac.rb"

binding.pry

server = Sumac::Adapter::TCP.listen(2000)

messenger = server.accept

binding.pry

messenger.close

messenger = server.accept

binding.pry

messenger.close

server.close
