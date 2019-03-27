require 'json'
require 'thread'
require 'quack_concurrency'
require 'forwardable'

require 'monkey_patch/array.rb'
require 'monkey_patch/object.rb'

require 'sumac/calls/local_call.rb'
require 'sumac/calls/local_calls.rb'
require 'sumac/calls/remote_call.rb'
require 'sumac/calls/remote_calls.rb'
require 'sumac/calls.rb'
require 'sumac/closer.rb'
require 'sumac/connection/scheduler.rb'
require 'sumac/connection.rb'
require 'sumac/directive_queue.rb'
require 'sumac/error.rb'
require 'sumac/exposed_object.rb'
require 'sumac/argument_error.rb'
require 'sumac/closed_messenger_error.rb'
require 'sumac/closed_object_request_broker_error.rb'
require 'sumac/handshake.rb'
require 'sumac/id.rb'
require 'sumac/id_allocator.rb'
require 'sumac/local_object/expose_preferences.rb'
require 'sumac/local_object/instance_methods.rb'
require 'sumac/local_object/singleton_methods.rb'
require 'sumac/local_object.rb'
#require 'sumac/local_object_child.rb'
require 'sumac/messages/base.rb'
require 'sumac/messages/component/array.rb'
require 'sumac/messages/component/boolean.rb'
require 'sumac/messages/component/exception.rb'
require 'sumac/messages/component/exposed.rb'
#require 'sumac/messages/component/exposed_child.rb'
require 'sumac/messages/component/float.rb'
require 'sumac/messages/component/integer.rb'
require 'sumac/messages/component/internal_exception.rb'
require 'sumac/messages/component/map.rb'
require 'sumac/messages/component/null.rb'
require 'sumac/messages/component/string.rb'
require 'sumac/messages/component.rb'
require 'sumac/messages/message.rb'
require 'sumac/messages/call_request.rb'
require 'sumac/messages/call_response.rb'
require 'sumac/messages/compatibility.rb'
require 'sumac/messages/forget.rb'
require 'sumac/messages/initialization.rb'
require 'sumac/messages/shutdown.rb'
require 'sumac/messages.rb'
require 'sumac/messenger.rb'
require 'sumac/object_request_broker.rb'
require 'sumac/objects/local_references.rb'
require 'sumac/objects/reference/scheduler.rb'
require 'sumac/objects/reference.rb'
require 'sumac/objects/local_reference.rb'
require 'sumac/objects/remote_reference.rb'
require 'sumac/objects/remote_references.rb'
require 'sumac/objects.rb'
require 'sumac/protocol_error.rb'
require 'sumac/remote_entry.rb'
require 'sumac/remote_error.rb'
require 'sumac/remote_object.rb'
#require 'sumac/remote_object_child.rb'
require 'sumac/shutdown.rb'
require 'sumac/stale_object_error.rb'
require 'sumac/unexposed_method_error.rb'
require 'sumac/unexposed_object_error.rb'


module Sumac

  # Maximum depth of an object passed as an argument or returned.
  MAX_OBJECT_NESTING_DEPTH = 100

  # +include+ or +extend+ to expose objects.
  # @note for a more intuitive naming convention {LocalObject} will be referenced
  #   by the code base, however {Expose} should be used by the application.
  # A {LocalObject} is an object that can be shared with the remote endpoint.
  # @see LocalObject for examples of how to use it by the application
  Expose = LocalObject

end
