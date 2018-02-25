module Sumac
  class Message
    class ID
      
      
      def self.parse(json)
        raise unless valid?(json)
        case json[0]
        when 'L'
          orgin = :local
        when 'R'
          orgin = :remote
        end
        new(json[1..-1].to_i, orgin)
      end
      
      
      def self.valid?(json)
        json.is_a?(String) && (json[0] == 'L' || json[0] == 'R')
      end
      
      
      attr_reader :number
      
      
      def initialize(number, orgin)
        @number = number
        raise unless orgin == :local || orgin == :remote
        @orgin = orgin
      end
      
      
      def local?
        @orgin == :local
      end
      
      
      def remote?
        @orgin == :remote
      end
      
      
      def to_json
        "#{local? ? 'L' : 'R'}#{number.to_s}"
      end
      
      
      def invert_orgin
        @orgin = local? ? :remote : :local
        @orgin
      end
      
      
    end
  end
end
