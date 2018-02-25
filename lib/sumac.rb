require 'socket'
require 'pry'
require 'json'
require 'thread'

require_relative "core_extensions.rb"

require_relative "sumac/emittable.rb"
require_relative "sumac/call_dispatcher.rb"
require_relative "sumac/call_processor.rb"
require_relative "sumac/closed.rb"
require_relative "sumac/connection.rb"
require_relative "sumac/exposed_object.rb"
require_relative "sumac/handshake.rb"
require_relative "sumac/id_allocator.rb"
require_relative "sumac/message.rb"
require_relative "sumac/message/exchange.rb"
require_relative "sumac/message/object.rb"
require_relative "sumac/message/exchange/request_response.rb"
require_relative "sumac/message/exchange/call_request.rb"
require_relative "sumac/message/exchange/call_response.rb"
require_relative "sumac/message/exchange/notification.rb"
require_relative "sumac/message/exchange/compatibility_notification.rb"
require_relative "sumac/message/exchange/dispatch.rb"
require_relative "sumac/message/exchange/initialization_notification.rb"
require_relative "sumac/message/exchange/shutdown_notification.rb"
require_relative "sumac/message/object/array.rb"
require_relative "sumac/message/object/boolean.rb"
require_relative "sumac/message/object/dispatch.rb"
require_relative "sumac/message/object/exposed.rb"
require_relative "sumac/message/object/float.rb"
require_relative "sumac/message/object/hash_table.rb"
require_relative "sumac/message/object/integer.rb"
require_relative "sumac/message/object/null.rb"
require_relative "sumac/message/object/string.rb"
require_relative "sumac/message_error.rb"
require_relative "sumac/network.rb"
require_relative "sumac/orchestrator.rb"
require_relative "sumac/receiver.rb"
require_relative "sumac/reference.rb"
require_relative "sumac/reference/local.rb"
require_relative "sumac/reference/local_manager.rb"
require_relative "sumac/reference/remote.rb"
require_relative "sumac/reference/remote_manager.rb"
require_relative "sumac/remote_object.rb"
require_relative "sumac/shutdown.rb"
require_relative "sumac/stale_object.rb"
require_relative "sumac/synchronizer.rb"
require_relative "sumac/transmitter.rb"
require_relative "sumac/waiter.rb"


Thread.abort_on_exception = true

module Sumac

  def self.connect(ip, port, entry = nil)
    socket = TCPSocket.new(ip, port)
    #entry = entry_class ? entry_class.new : nil
    connection = Sumac::Connection.new(socket, entry)
    connection
  end
  
  def self.listen(port, entry = nil)
    server = TCPServer.new(port)
    socket = server.accept
    #entry = entry_class ? entry_class.new : nil
    connection = Sumac::Connection.new(socket, entry)
    connection
  end
end
