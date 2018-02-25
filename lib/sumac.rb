require 'socket'
require 'pry'
require 'json'
require 'thread'
require 'celluloid'
require 'celluloid/io'

require_relative "core_extensions.rb"

require_relative "sumac/adapter.rb"
require_relative "sumac/adapter/closed.rb"
require_relative "sumac/adapter/tcp.rb"
require_relative "sumac/adapter/tcp/messenger.rb"
require_relative "sumac/adapter/tcp/server.rb"
require_relative "sumac/adapter/connection_error.rb"
require_relative "sumac/argument_error.rb"
require_relative "sumac/emittable.rb"
require_relative "sumac/call_dispatcher.rb"
require_relative "sumac/call_processor.rb"
require_relative "sumac/celluloid_mutex.rb"
require_relative "sumac/closed.rb"
require_relative "sumac/connection.rb"
require_relative "sumac/exposed_object.rb"
require_relative "sumac/handshake.rb"
require_relative "sumac/id_allocator.rb"
require_relative "sumac/message.rb"
require_relative "sumac/message/exchange.rb"
require_relative "sumac/message/object.rb"
require_relative "sumac/message/exchange/id.rb"
require_relative "sumac/message/exchange/call_request.rb"
require_relative "sumac/message/exchange/call_response.rb"
require_relative "sumac/message/exchange/notification.rb"
require_relative "sumac/message/exchange/compatibility_notification.rb"
require_relative "sumac/message/exchange/forget_notification.rb"
require_relative "sumac/message/exchange/dispatch.rb"
require_relative "sumac/message/exchange/initialization_notification.rb"
require_relative "sumac/message/exchange/shutdown_notification.rb"
require_relative "sumac/message/object/array.rb"
require_relative "sumac/message/object/boolean.rb"
require_relative "sumac/message/object/dispatch.rb"
require_relative "sumac/message/object/exception.rb"
require_relative "sumac/message/object/exposed.rb"
require_relative "sumac/message/object/float.rb"
require_relative "sumac/message/object/hash_table.rb"
require_relative "sumac/message/object/integer.rb"
require_relative "sumac/message/object/native_exception.rb"
require_relative "sumac/message/object/null.rb"
require_relative "sumac/message/object/string.rb"
require_relative "sumac/message_error.rb"
require_relative "sumac/no_method_error.rb"
require_relative "sumac/orchestrator.rb"
require_relative "sumac/receiver.rb"
require_relative "sumac/reference.rb"
require_relative "sumac/reference/local.rb"
require_relative "sumac/reference/local_manager.rb"
require_relative "sumac/native_exception.rb"
require_relative "sumac/reference/remote.rb"
require_relative "sumac/reference/remote_manager.rb"
require_relative "sumac/remote_object.rb"
require_relative "sumac/shutdown.rb"
require_relative "sumac/stale_object.rb"
require_relative "sumac/synchronizer.rb"
require_relative "sumac/transmitter.rb"
require_relative "sumac/unexposable_error.rb"
require_relative "sumac/waiter.rb"


Thread.abort_on_exception = true

module Sumac

  def self.start(messenger, entry = nil)
    Sumac::Connection.new(messenger, entry)
  end
  
end
