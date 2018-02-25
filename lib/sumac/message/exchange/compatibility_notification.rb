module Sumac
  class Message
    class Exchange
      class CompatibilityNotification < Notification
      
        def initialize(orchestrator)
          super
          @protocol_version = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(Hash) &&
            json_structure['message_type'] == 'exchange' &&
            json_structure['exchange_type'] == 'compatibility_notification'
          raise MessageError unless json_structure['protocol_version'].is_a?(Integer)
          @protocol_version = json_structure['protocol_version']
          nil
        end
        
        def to_json_structure
          raise MessageError unless setup?
          {
            'message_type' => 'exchange',
            'exchange_type' => 'compatibility_notification',
            'protocol_version' => @protocol_version
          }
        end
        
        def protocol_version
          raise MessageError unless setup?
          @protocol_version
        end
        
        def protocol_version=(new_protocol_version)
          raise MessageError unless new_protocol_version.is_a?(Integer)
          @protocol_version = new_protocol_version
        end
        
        def invert_orgin
          raise MessageError unless setup?
          nil
        end
        
        private
        
        def setup?
          @protocol_version != nil
        end
        
      end
    end
  end
end
