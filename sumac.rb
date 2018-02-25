require 'socket'
require 'pry'
require 'json'
require 'celluloid'
require 'celluloid/io'

require_relative 'core_extensions.rb'

require_relative 'sumac/id_allocator.rb'
require_relative 'sumac/object_reference/translater.rb'
require_relative 'sumac/request/translater.rb'

require_relative 'sumac/connection.rb'
require_relative 'sumac/exposed_object.rb'
require_relative 'sumac/global_id_allocator.rb'
require_relative 'sumac/message.rb'
require_relative 'sumac/message_router.rb'
require_relative 'sumac/remote_object_wrapper.rb'
require_relative 'sumac/request_manager.rb'
require_relative 'sumac/waiter.rb'
require_relative 'sumac/message/id.rb'
require_relative 'sumac/object_reference/local.rb'
require_relative 'sumac/object_reference/local_entry.rb'
require_relative 'sumac/object_reference/local_manager.rb'
require_relative 'sumac/object_reference/remote.rb'
require_relative 'sumac/object_reference/remote_entry.rb'
require_relative 'sumac/object_reference/remote_manager.rb'
require_relative 'sumac/request/inbound_call.rb'
require_relative 'sumac/request/inbound_entry.rb'
require_relative 'sumac/request/outbound_call.rb'
require_relative 'sumac/request/outbound_entry.rb'

module Sumac  
end
