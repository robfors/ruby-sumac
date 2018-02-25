module Sumac
  module Request
    module Translater
    
    
      def reference_to_message(object)
        case
        when object.is_a?(ObjectReference::Local)
          Message::ID.new(object.exposed_id, :local)
        when object.is_a?(ObjectReference::Remote)
          Message::ID.new(object.exposed_id, :remote)
        when [NilClass, TrueClass, FalseClass, String, Numeric].any? { |klass| object.is_a?(klass) }
          object
        when object.is_a?(Array)
          object.map { |element| reference_to_message(element) }
        when object.is_a?(Hash)
          object.map { |key, value| [key, reference_to_message(value)] }.to_h
        else
          raise 'system error'
        end
      end
      
      
      def message_to_reference(object)
        case
        when object.is_a?(Message::ID)
          if object.local?
            @connection.local_reference_manager.retrieve(object.number)
          else
            @connection.remote_reference_manager.retrieve_or_create(object.number)
          end
        when [NilClass, TrueClass, FalseClass, String, Numeric].any? { |klass| object.is_a?(klass) }
          object
        when object.is_a?(Array)
          object.map { |element| message_to_reference(element) }
        when object.is_a?(Hash)
          object.map { |key, value| [key, message_to_reference(value)] }.to_h
        else
          raise 'system error'
        end
      end
      
      
    end
  end
end
