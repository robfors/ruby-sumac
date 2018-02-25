module Sumac
  class Message < Hash
    include MessageHelper
    
    def self.build(hash)
      new(hash)
    end
    
    def self.parse(text)
      new(text)
    end
    
    def initialize(arg)
      super
      raise unless args.length == 1
      @text = args[:text]
       ||= JSON.parse(text)
      
      
    end
    
    def text
      @text ||= hash.to_json
    end
    
    def type
      hash['type']
    end
    
    def sequence_number
      sequence_number
    end
    
    def sequence_number=(new_sequence_number)
      hash['sequence_number']
    end
    
  end
end
