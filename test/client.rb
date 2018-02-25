require_relative "../lib/sumac.rb"

c = []

1_000.times do
  messenger = Sumac::Adapter::TCP.connect('127.0.0.1', 2001)
  connection = Sumac.start(messenger, nil)
  
  connection.on(:network_error) { puts "***NETWORK_ERROR***" }
  connection.on(:shutdown) { puts "***SHUTDOWN***" }
  connection.on(:close) { messenger.close; puts "***CLOSE***" }
  
  entry = connection.entry
  
  u = entry.new_user('rob')
  u.username
  u.forget
  c << connection
end

binding.pry

#t = Thread.new do
#  begin
#    sleep 1
#    puts entry.test
#  rescue Sumac::StaleObject
#    puts 'good'
#  end
#end

#mutex = Mutex.new
#$count = 0

#threads = 5.times.map do
#  Thread.new do
#    100.times do
#      entry.test
#      mutex.synchronize { $count += 1; puts $count }
#    end
#  end
#end
#
#threads.each(&:join)

#sleep 2

connection.close

#binding.pry

#puts entry.new_user('rob').tt({},[44.44])

#puts connection.entry.new_user.username

#binding.pry



#t.join
