class Sumac
  class Message
    class Exchange
      module Dispatch
      
        def self.from_json(connection, json)
          json_structure = JSON.parse(json)
          from_json_structure(connection, json_structure)
        end
        
        def self.from_json_structure(connection, json_structure)
          raise MessageError unless json_structure.is_a?(Hash) && json_structure['message_type'] == 'exchange'
          case json_structure['exchange_type']
          when 'compatibility_notification'
            CompatibilityNotification.from_json_structure(connection, json_structure)
          when 'initialization_notification'
            InitializationNotification.from_json_structure(connection, json_structure)
          when 'shutdown_notification'
            ShutdownNotification.from_json_structure(connection, json_structure)
          when 'forget_notification'
            ForgetNotification.from_json_structure(connection, json_structure)
          when 'call_request'
            CallRequest.from_json_structure(connection, json_structure)
          when 'call_response'
            CallResponse.from_json_structure(connection, json_structure)
          else
            raise MessageError
          end
        end
        
      end
    end
  end
end
