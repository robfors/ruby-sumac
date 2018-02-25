class Sumac
  class Message
    class Exchange
      class ForgetNotification < Notification
        
        def initialize(connection)
          super
          @orgin = nil
          @id = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(Hash) &&
            json_structure['message_type'] == 'exchange' &&
            json_structure['exchange_type'] == 'forget_notification'
          raise MessageError unless json_structure['orgin'] == 'local' || json_structure['orgin'] == 'remote'
          @orgin = json_structure['orgin']
          raise MessageError unless json_structure['id'].is_a?(::Integer)
          @id = json_structure['id']
        end
        
        def to_json_structure
          raise MessageError unless setup?
          {
            'message_type' => 'exchange',
            'exchange_type' => 'forget_notification',
            'orgin' => @orgin,
            'id' => @id
          }
        end
        
        def reference
          raise MessageError unless setup?
          case @orgin
          when 'local'
            reference = @connection.local_references.from_id(@id)
            raise MessageError unless reference
            reference
          when 'remote'
            @connection.remote_references.from_id(@id)
          end
        end
        
        def reference=(new_reference)
          case new_reference
          when LocalReference
            @orgin = 'local'
          when RemoteReference
            @orgin = 'remote'
          else
            raise MessageError
          end
          @id = new_reference.exposed_id
          nil
        end
        
        def invert_orgin
          raise MessageError unless setup?
          case @orgin
          when 'local'
            @orgin = 'remote'
          when 'remote'
            @orgin = 'local'
          end
          nil
        end
        
        private
        
        def setup?
          @orgin != nil && @id != nil
        end
        
      end
    end
  end
end
