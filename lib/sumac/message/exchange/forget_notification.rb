module Sumac
  class Message
    class Exchange
      class ForgetNotification < Notification
        include ID
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(Hash) &&
            json_structure['message_type'] == 'exchange' &&
            json_structure['exchange_type'] == 'forget_notification'
          raise MessageError unless json_structure['id'].is_a?(Integer)
          @id = json_structure['id']
          nil
        end
        
        def to_json_structure
          {
            'message_type' => 'exchange',
            'exchange_type' => 'forget_notification',
            'id' => @id
          }
        end
        
        def invert_orgin
          nil
        end
        
      end
    end
  end
end
