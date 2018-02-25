module Sumac
  module Message
    module Exchange
      module Dispatch
      
        def self.from_json(connection, json)
          json_structure = JSON.parse(json)
          from_json_structure(connection, json_structure)
        end
        
        def self.from_json_structure(connection, json_structure)
          raise unless json_structure.is_a?(Hash) && json_structure['message_type'] == 'exchange'
          case json_structure['exchange_type']
          when 'handshake_request'
            HandshakeRequest.from_json_structure(connection, json_structure)
          when 'handshake_response'
            HandshakeResponse.from_json_structure(connection, json_structure)
          when 'call_request'
            CallRequest.from_json_structure(connection, json_structure)
          when 'call_response'
            CallResponse.from_json_structure(connection, json_structure)
          else
            raise
          end
        end
        
      end
    end
  end
end
