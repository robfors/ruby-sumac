module Sumac
  module Message
    module Object
      class Exposed < Object
      
        def initialize(connection)
          super
          @orgin = nil
          @id = nil
        end
        
        def parse_json_structure(json_structure)
          raise unless json_structure.is_a?(::Hash) &&
            json_structure['message_type'] == 'object' &&
            json_structure['object_type'] == 'exposed'
          raise unless json_structure['orgin'] == 'local' || json_structure['orgin'] == 'remote'
          @orgin = json_structure['orgin']
          raise unless json_structure['id'].is_a?(::Integer)
          @id = json_structure['id']
          nil
        end
        
        def parse_native_object(native_object)
          case
          when native_object.is_a?(ExposedObject)
            @orgin = 'local'
            @id = @connection.local_reference_manager.load(native_object).exposed_id
          when native_object.is_a?(RemoteObject)
            @orgin = 'remote'
            @id = @connection.remote_reference_manager.load(native_object).exposed_id
          else
            raise
          end
          nil
        end
        
        def to_json_structure
          raise unless setup?
          {
            'message_type' => 'object',
            'object_type' => 'exposed',
            'orgin' => @orgin,
            'id' => @id
          }
        end
        
        def to_native_object
          raise unless setup?
          case @orgin
          when 'local'
            @connection.local_reference_manager.retrieve(@id).exposed_object
          when 'remote'
            @connection.remote_reference_manager.find_or_create(@id).remote_object
          end
        end
        
        def invert_orgin
          raise unless setup?
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
