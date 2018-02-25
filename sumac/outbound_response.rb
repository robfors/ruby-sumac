module Sumac
  class OutboundResponse < MessageHelper
  
    def initialize(connection, request, object)
      @connection = connection
      @request = request
      @object = object
      @processed = false
    end
    
    def message
      raise 'Already processed' if @processed
      hash = {'type' => 'response'}
      hash['sequence_number'] = @request.sequence_number
      hash['value'] = object_to_message(@object)
      @processed = false
      message = hash.to_json
    end
    
  end
end
