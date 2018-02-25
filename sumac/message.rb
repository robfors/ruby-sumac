module Sumac
  class Message
    
      
    def self.parse(json)
      new_message = new
      new_message.parse(json)
      return new_message
    end
    
    
    def initialize
      @hash = {}
    end
    
    
    def parse(json)
      raise unless @hash.empty?
      hash = decode_ids(JSON.parse(json))
      raise unless hash.is_a?(Hash)
      @hash = hash
    end
    
    
    def to_json
      encode_ids(@hash).to_json
    end
    
    
    def [](attribute)
      @hash[attribute]
    end
    
    
    def []=(attribute, value)
      @hash[attribute] = value
    end
    
    
    def invert_orgin
      invert_orgin_helper(@hash)
      nil
    end
      
    
    private
    
    
    def invert_orgin_helper(object)
      case
      when object.is_a?(ID)
        object.invert_orgin
      when [NilClass, TrueClass, FalseClass, String, Numeric].any? { |klass| object.is_a?(klass) }
        object
      when object.is_a?(Array)
        object.map { |element| invert_orgin_helper(element) }
      when object.is_a?(Hash)
        object.map { |key, value| [key, invert_orgin_helper(value)] }.to_h
      else
        raise 'system error'
      end
    end
    
    
    def encode_ids(object)
      case
      when object.is_a?(ID)
        object.to_json
      when [NilClass, TrueClass, FalseClass, String, Numeric].any? { |klass| object.is_a?(klass) }
        object
      when object.is_a?(Array)
        object.map { |element| encode_ids(element) }
      when object.is_a?(Hash)
        object.map { |key, value| [key, encode_ids(value)] }.to_h
      else
        raise 'system error'
      end
    end
    
    
    def decode_ids(object)
      case
      when ID.valid?(object)
        ID.parse(object)
      when [NilClass, TrueClass, FalseClass, String, Numeric].any? { |klass| object.is_a?(klass) }
        object
      when object.is_a?(Array)
        object.map { |element| decode_ids(element) }
      when object.is_a?(Hash)
        object.map { |key, value| [key, decode_ids(value)] }.to_h
      else
        raise 'system error'
      end
    end
    
    
  end
end
