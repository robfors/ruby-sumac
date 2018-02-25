module Sumac
  class MessageHelper
  
    def inbound_id_adjustment?
      false
    end
    
    def object_to_message(object)
      case
      when object.is_a?(ReachableObject)
        if adjust_id?
          @connection.object_id_manager.convert_remote_to_local(object.id)
        else
          object.id
        end
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
    
    def message_to_object(object)
      if object.is_a?(Integer)
        if adjust_id?
          id = @connection.object_id_manager.convert_local_to_remote(object)
        else
          id = object
        end
        if @connection.object_id_manager.local?(id)
          LocalReachableObject.new(@connection, id)
        else
          RemoteReachableObject.new(@connection, id)
        end
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
