require 'socket'
require 'pry'
require 'json'
require 'celluloid'

require_relative 'core_extensions.rb'

require_relative 'sumac/id_manager.rb'
require_relative 'sumac/message_helper.rb'
require_relative 'sumac/object_reference.rb'

require_relative 'sumac/connection.rb'
#require_relative 'sumac/eventable.rb'
require_relative 'sumac/exposed_object.rb'
require_relative 'sumac/global_id_manager.rb'
require_relative 'sumac/inbound_reqest.rb'
require_relative 'sumac/inbound_request_manager.rb'
require_relative 'sumac/local_object_reference.rb'
require_relative 'sumac/local_reference_manager.rb'
require_relative 'sumac/message.rb'
require_relative 'sumac/message_manager.rb'
require_relative 'sumac/outbound_reqest.rb'
require_relative 'sumac/outbound_request_manager.rb'
require_relative 'sumac/remote_object_reference.rb'
require_relative 'sumac/remote_object_wrapper.rb'
require_relative 'sumac/remote_reference_manager.rb'
require_relative 'sumac/waiter.rb'


module Sumac  
end
