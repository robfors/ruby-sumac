require 'socket'
require 'pry'
require 'json'
require 'thread'

require_relative "../../quack_concurrency/lib/quack_concurrency.rb"
require_relative "../../state_machine/state_machine.rb"
require_relative "../../emittable/emittable.rb"

require_relative "core_extensions.rb"

require_relative "sumac/adapter.rb"
require_relative "sumac/adapter/closed.rb"
require_relative "sumac/argument_error.rb"
require_relative "sumac/emittable.rb"
require_relative "sumac/call_dispatcher.rb"
require_relative "sumac/call_processor.rb"
require_relative "sumac/closed_error.rb"
require_relative "sumac/closer.rb"
require_relative "sumac/connection.rb"
require_relative "sumac/exposed_object.rb"
require_relative "sumac/handshake.rb"
require_relative "sumac/id_allocator.rb"
require_relative "sumac/reference.rb"
require_relative "sumac/local_reference.rb"
require_relative "sumac/local_references.rb"
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
require_relative "sumac/messenger.rb"
require_relative "sumac/no_method_error.rb"
require_relative "sumac/native_error.rb"
require_relative "sumac/remote_entry.rb"
require_relative "sumac/remote_object.rb"
require_relative "sumac/remote_reference.rb"
require_relative "sumac/remote_references.rb"
require_relative "sumac/scheduler.rb"
require_relative "sumac/shutdown.rb"
require_relative "sumac/state_machine.rb"
require_relative "sumac/stale_object_error.rb"
require_relative "sumac/unexposable_object_error.rb"
require_relative "sumac/worker_pool.rb"


class Sumac
  include Emittable
  
  def initialize(duck_types: {}, entry: nil, messenger: , workers: 1)
    @connection = Connection.new(self, duck_types: duck_types, entry: entry, messenger: messenger, workers: workers)
    @connection.scheduler.run
  end
  
  def close
    @connection.closer.close
    nil
  end
  
  def entry
    @connection.remote_entry.get
  end
  
  def join
    @connection.closer.join
  end
  
  #def kill
  #end
  
end
