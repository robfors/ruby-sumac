module Sumac
  module Message
    module Exchange
      class HandshakeResponse < Exchange
      
        def initialize(connection)
          super
          @status = nil
        end
        
        def parse_json_structure(json_structure)
          raise unless json_structure.is_a?(Hash) &&
            json_structure['message_type'] == 'exchange' &&
            json_structure['exchange_type'] == 'handshake_response'
          raise unless json_structure['id'].is_a?(Integer)
          @id = json_structure['id']
          raise unless json_structure['status'].is_a?(String)
          @status = json_structure['status']
        end
        
        def to_json_structure
          raise unless setup?
          {
            'message_type' => 'exchange',
            'exchange_type' => 'handshake_response',
            'id' => @id,
            'status' => @status
          }
        end
        
        def status
          raise unless setup?
          @status
        end
        
        def status=(new_status)
          raise unless new_status.is_a?(String)
          @status = new_status
        end
        
        def invert_orgin
          raise unless setup?
          nil
        end
        
        private
        
        def setup?
          super && @status != nil
        end
        
      end
    end
  end
end
