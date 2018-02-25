module Sumac
  class Message
    class Exchange
      class CompatibilityHandshake < Exchange
      
        def initialize(connection)
          super
          @protocol_version = nil
        end
        
        def parse_json_structure(json_structure)
          raise unless json_structure.is_a?(Hash) &&
            json_structure['message_type'] == 'exchange' &&
            json_structure['exchange_type'] == 'compatibility_handshake'
          raise unless json_structure['protocol_version'].is_a?(Integer)
          @protocol_version = json_structure['protocol_version']
        end
        
        def to_json_structure
          raise unless setup?
          {
            'message_type' => 'exchange',
            'exchange_type' => 'compatibility_handshake',
            'protocol_version' => @protocol_version
          }
        end
        
        def protocol_version
          raise unless setup?
          @protocol_version
        end
        
        def protocol_version=(new_protocol_version)
          raise unless new_protocol_version.is_a?(Integer)
          @protocol_version = new_protocol_version
        end
        
        def invert_orgin
          raise unless setup?
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
