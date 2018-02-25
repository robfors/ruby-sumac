class Sumac
  class Message
    class Exchange
      class CallResponse < Base
        include ID
        
        def initialize(connection)
          super
          @return_value = nil
          @exception = nil
        end
        
        def parse_json_structure(json_structure)
          raise MessageError unless json_structure.is_a?(Hash) &&
            json_structure['message_type'] == 'exchange' &&
            json_structure['exchange_type'] == 'call_response'
          raise MessageError unless json_structure['id'].is_a?(Integer)
          @id = json_structure['id']
          case
          when json_structure['return_value'] && !json_structure['exception']
            @return_value = Object.from_json_structure(@connection, json_structure['return_value'])
          when !json_structure['return_value'] && json_structure['exception']
            @exception = Object.from_json_structure(@connection, json_structure['exception'])
            raise MessageError unless @exception.class.one_of?(Object::Exception, Object::NativeException)
          else
            raise MessageError
          end
          nil
        end
        
        def to_json_structure
          raise MessageError unless setup?
          json_structure =
            {
              'message_type' => 'exchange',
              'exchange_type' => 'call_response',
              'id' => @id
            }
          if @return_value
            json_structure['return_value'] = @return_value.to_json_structure
          else
            json_structure['exception'] = @exception.to_json_structure
          end
          json_structure
        end
        
        def return_value
          raise MessageError unless setup?
          @return_value == nil ? nil : @return_value.to_native_object
        end
        
        def return_value=(new_return_value)
          raise unless @exception == nil
          @return_value = Object.from_native_object(@connection, new_return_value)
        end
        
        def exception
          raise MessageError unless setup?
          @exception == nil ? nil : @exception.to_native_object
        end
        
        def exception=(new_exception_value)
          raise unless @return_value == nil
          @exception = Object.from_native_object(@connection, new_exception_value)
          raise MessageError unless @exception.class.one_of?(Object::Exception, Object::NativeException)
        end
        
        def invert_orgin
          raise MessageError unless setup?
          @return_value.invert_orgin if @return_value.respond_to?(:invert_orgin)
          nil
        end
        
        private
        
        def setup?
          super && ((@return_value != nil) ^ (@exception != nil))
        end
        
      end
    end
  end
end
