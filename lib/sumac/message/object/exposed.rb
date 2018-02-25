module Sumac
  class Message
    class Object
      class Exposed < Object
      
        def initialize(orchestrator)
          super
          @orgin = nil
          @id = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(::Hash) &&
            json_structure['message_type'] == 'object' &&
            json_structure['object_type'] == 'exposed'
          raise MessageError unless json_structure['orgin'] == 'local' || json_structure['orgin'] == 'remote'
          @orgin = json_structure['orgin']
          raise MessageError unless json_structure['id'].is_a?(::Integer)
          @id = json_structure['id']
          nil
        end
        
        def parse_native_object(native_object)
          case
          when native_object.is_a?(ExposedObject)
            @orgin = 'local'
            @id = @orchestrator.local_references.load(native_object).exposed_id
          when native_object.is_a?(RemoteObject)
            @orgin = 'remote'
            @id = @orchestrator.remote_references.load(native_object).exposed_id
          else
            raise MessageError
          end
          nil
        end
        
        def to_json_structure
          raise MessageError unless setup?
          {
            'message_type' => 'object',
            'object_type' => 'exposed',
            'orgin' => @orgin,
            'id' => @id
          }
        end
        
        def to_native_object
          raise MessageError unless setup?
          case @orgin
          when 'local'
            native_object = @orchestrator.local_references.retrieve(@id).exposed_object
            raise MessageError unless native_object
            native_object
          when 'remote'
            @orchestrator.remote_references.find_or_create(@id).remote_object
          end
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
