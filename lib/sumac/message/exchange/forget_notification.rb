module Sumac
  class Message
    class Exchange
      class ForgetNotification < Notification
        
        def initialize(orchestrator)
          super
          @exposed_object = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(Hash) &&
            json_structure['message_type'] == 'exchange' &&
            json_structure['exchange_type'] == 'forget_notification'
          @exposed_object = Object::Exposed.from_json_structure(@orchestrator, json_structure['exposed_object'])
          nil
        end
        
        def to_json_structure
          {
            'message_type' => 'exchange',
            'exchange_type' => 'forget_notification',
            'exposed_object' => @exposed_object.to_json_structure
          }
        end
        
        def exposed_object
          raise MessageError unless setup?
          @exposed_object.to_native_object
        end
        
        def exposed_object=(new_exposed_object)
          raise MessageError unless new_exposed_object.is_a?(ExposedObject) ||
            new_exposed_object.is_a?(RemoteObject)
          @exposed_object = Object::Exposed.from_native_object(@orchestrator, new_exposed_object)
        end
        
        def invert_orgin
          raise MessageError unless setup?
          @exposed_object.invert_orgin
          nil
        end
        
        private
        
        def setup?
          @exposed_object != nil
        end
        
      end
    end
  end
end
