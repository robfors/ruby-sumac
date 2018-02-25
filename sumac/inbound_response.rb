module Sumac
  class InboundResponse < MessageHelper
  
    def initialize(connection, message)
      @connection = connection
      @message = message
      @processed = false
    end
    
    def process
      raise 'Already processed' if @processed
      hash = JSON.parse(@message)
      @sequence_number = hash['sequence_number']
      @value = message_to_object(hash['value'])
      @processed = false
      nil
    end
    
    def sequence_number
      process unless @processed
      @sequence_number
    end
    
    def value
      process unless @processed
      @value
    end
    
  end
end
