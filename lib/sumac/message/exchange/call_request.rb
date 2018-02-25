class Sumac
  class Message
    class Exchange
      class CallRequest < Base
        include ID
        
        def initialize(connection)
          super
          @exposed_object = nil
          @child = nil
          @method_name = nil
          @arguments = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(Hash) &&
            json_structure['message_type'] == 'exchange' &&
            json_structure['exchange_type'] == 'call_request'
          raise MessageError unless json_structure['id'].is_a?(Integer)
          @id = json_structure['id']
          exposed_object = Object.from_json_structure(@connection, json_structure['exposed_object'])
          raise MessageError unless exposed_object.is_a?(Object::Exposed) || exposed_object.is_a?(Object::ExposedChild)
          @exposed_object = exposed_object
          raise MessageError unless json_structure['method_name'].is_a?(String)
          @method_name = json_structure['method_name']
          raise MessageError unless json_structure['arguments'].is_a?(Array)
          @arguments = json_structure['arguments'].map do |argument_json_structure|
            Object.from_json_structure(@connection, argument_json_structure)
          end
          nil
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
          raise MessageError unless setup?
          @exposed_object.to_native_object
        end
        
        def exposed_object=(new_exposed_object)
          unless new_exposed_object.is_a?(RemoteObject) || new_exposed_object.is_a?(RemoteObjectChild) ||
                 new_exposed_object.respond_to?(:__sumac_exposed_object__)
            raise MessageError
          end
          @exposed_object = Object.from_native_object(@connection, new_exposed_object)
        end
        
        def method_name
          raise MessageError unless setup?
          @method_name
        end
        
        def method_name=(new_method_name)
          raise MessageError unless new_method_name.is_a?(String)
          @method_name = new_method_name
        end
        
        def arguments
          raise MessageError unless setup?
          @arguments.map(&:to_native_object)
        end
        
        def arguments=(new_arguments)
          raise MessageError unless new_arguments.is_a?(Array)
          @arguments = new_arguments.map do |native_argument|
            Object.from_native_object(@connection, native_argument)
          end
        end
        
        def invert_orgin
          raise MessageError unless setup?
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
