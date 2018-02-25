module Sumac
  class Message
    class Exchange
      class CallRequest < RequestResponse
      
        def initialize(connection)
          super
          @exposed_object = nil
          @method_name = nil
          @arguments = nil
        end
        
        def parse_json_structure(json_structure)
          raise unless json_structure.is_a?(Hash) &&
            json_structure['message_type'] == 'exchange' &&
            json_structure['exchange_type'] == 'call_request'
          raise unless json_structure['id'].is_a?(Integer)
          @id = json_structure['id']
          @exposed_object = Object::Exposed.from_json_structure(@connection, json_structure['exposed_object'])
          raise unless json_structure['method_name'].is_a?(String)
          @method_name = json_structure['method_name']
          raise unless json_structure['arguments'].is_a?(Array)
          @arguments = json_structure['arguments'].map do |argument_json_structure|
            Object::Dispatch.from_json_structure(@connection, argument_json_structure)
          end
        end
        
        def to_json_structure
          raise unless setup?
          {
            'message_type' => 'exchange',
            'exchange_type' => 'call_request',
            'id' => @id,
            'exposed_object' => @exposed_object.to_json_structure,
            'method_name' => @method_name,
            'arguments' => @arguments.map(&:to_json_structure)
          }
        end
        
        def exposed_object
          raise unless setup?
          @exposed_object.to_native_object
        end
        
        def exposed_object=(new_exposed_object)
          raise unless new_exposed_object.is_a?(ExposedObject) || new_exposed_object.is_a?(RemoteObject)
          @exposed_object = Object::Exposed.from_native_object(@connection, new_exposed_object)
        end
        
        def method_name
          raise unless setup?
          @method_name
        end
        
        def method_name=(new_method_name)
          raise unless new_method_name.is_a?(String)
          @method_name = new_method_name
        end
        
        def arguments
          raise unless setup?
          @arguments.map(&:to_native_object)
        end
        
        def arguments=(new_arguments)
          raise unless new_arguments.is_a?(Array)
          @arguments = new_arguments.map do |native_argument|
            Object::Dispatch.from_native_object(@connection, native_argument)
          end
        end
        
        def invert_orgin
          raise unless setup?
          @exposed_object.invert_orgin
          @arguments.each { |argument| argument.invert_orgin if argument.respond_to?(:invert_orgin) }
          nil
        end
        
        private
        
        def setup?
          super && @exposed_object != nil && @method_name != nil && @arguments != nil
        end
        
      end
    end
  end
end
