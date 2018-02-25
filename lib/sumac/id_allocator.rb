class Sumac
  class IDAllocator
    
    def self.valid?(id)
      id.is_a?(Integer) && id >= 0
    end
    
    def initialize
      @allocated_ranges = []
      @mutex = Mutex.new
    end
    
    def valid?(id)
      self.class.valid?(id)
    end
    
    def allocate
      @mutex.lock
      if @allocated_ranges.empty?
        id = 0
      elsif @allocated_ranges.first.first == 0
        id = @allocated_ranges.first.last.succ
      else
        id = 0
      end
      
      preceding_range = @allocated_ranges.take_while{ |range| range.last < id }.last
      preceding_range_index = @allocated_ranges.find_index(preceding_range) if preceding_range
      
      following_range_index = @allocated_ranges.find_index { |range| range.first > id }
      following_range = @allocated_ranges[following_range_index] if following_range_index
      
      immediately_preceding_range = preceding_range if preceding_range && preceding_range.last.succ == id
      immediately_following_range = following_range if following_range && following_range.first.pred == id
      
      if immediately_preceding_range && immediately_following_range
        @allocated_ranges[preceding_range_index] = (preceding_range.first..following_range.last)
        @allocated_ranges.delete(following_range)
      elsif immediately_preceding_range
        @allocated_ranges[preceding_range_index] = (preceding_range.first..id)
      elsif immediately_following_range
        @allocated_ranges[following_range_index] = (id..following_range.last)
      else
        new_index = preceding_range ? preceding_range_index.succ : 0
        @allocated_ranges.insert(new_index, (id..id))
      end
      
      @mutex.unlock
      
      if block_given?
        begin
          yield(id)
        ensure
          free(id)
        end
      else
        id
      end
    end
    
    def free(id)
      @mutex.lock
      raise unless valid?(id) && allocated?(id)
      
      enclosing_range = enclosing_range(id)
      enclosing_range_index = @allocated_ranges.find_index(enclosing_range)
      
      if enclosing_range.size == 1
        @allocated_ranges.delete(enclosing_range)
      elsif enclosing_range.first == id
        @allocated_ranges[enclosing_range_index] = (enclosing_range.first.succ..enclosing_range.last)
      elsif enclosing_range.last == id
        @allocated_ranges[enclosing_range_index] = (enclosing_range.first..enclosing_range.last.pred)
      else
        @allocated_ranges[enclosing_range_index] = (enclosing_range.first..id.pred)
        @allocated_ranges.insert(enclosing_range_index.succ, (id.succ..enclosing_range.last))
      end
      
      @mutex.unlock
      nil
    end
    
    def allocated?(id)
      enclosing_range(id)
    end
    
    private
    
    def free?(id)
      !allocated?(id)
    end
    
    def enclosing_range(id)
      possible_range = @allocated_ranges.find{ |range| range.last >= id }
      return possible_range if possible_range && possible_range.first <= id
    end
    
  end
end
