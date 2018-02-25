class Sumac
  class Message
    class Exchange < Message
    
      def self.from_json_structure(connection, json_structure)
        raise MessageError unless json_structure.is_a?(Hash) && json_structure['message_type'] == 'exchange'
        exchange_class = 
          case json_structure['exchange_type']
          when 'compatibility_notification'
            CompatibilityNotification
          when 'initialization_notification'
            InitializationNotification
          when 'shutdown_notification'
            ShutdownNotification
          when 'forget_notification'
            ForgetNotification
          when 'call_request'
            CallRequest
          when 'call_response'
            CallResponse
          else
            raise MessageError
          end
        exchange = exchange_class.from_json_structure(connection, json_structure)
        exchange
      end
      
    end
  end
end
