module Sumac
  module MessageHelper
  
  
    def reference_to_message(object)
      case
      when object.is_a?(LocalObjectReference)
        'L' + object.exposed_id.to_s
      when object.is_a?(RemoteObjectReference)
        'R' + object.exposed_id.to_s
      when object.is_a?(String) || @object.is_a?(Numeric)
        object.to_json
      when object.is_a?(Array)
        object.map { |element| object_to_message(element) }.to_json
      when object.is_a?(Hash)
        object.map { |key, value| [key, object_to_message(element)] }.to_h.to_json
      else
        raise 'system error'
      end
    end
    
    
    def message_to_reference(object)
      if object.is_a?(String) && object[0] == 'L'
        @connection.local_reference_manager.retrieve(object[1..-1].to_i)
      elsif object.is_a?(String) && object[0] == 'R'
        @connection.remote_reference_manager.retrieve(object[1..-1].to_i)
      else
        object = JSON.parse(object)
        case
        when object.is_a?(String) || @object.is_a?(Numeric)
          object
        when object.is_a?(Array)
          object.map { |element| message_to_object(element) }
        when object.is_a?(Hash)
          object.map { |key, value| [key, message_to_object(element)] }.to_h
        else
          raise 'system error'
        end
      end
    end
    
    
  end
end
