class Sumac
  class Message
    class Exchange
      class ShutdownNotification < Notification
      
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(Hash) &&
            json_structure['message_type'] == 'exchange' &&
            json_structure['exchange_type'] == 'shutdown_notification'
          nil
        end
        
        def to_json_structure
          {
            'message_type' => 'exchange',
            'exchange_type' => 'shutdown_notification'
          }
        end
        
        def invert_orgin
          nil
        end
        
      end
    end
  end
end
