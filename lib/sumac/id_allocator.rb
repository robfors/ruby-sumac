module Sumac
  
  # Allocates ids. IDs can be returned then reallocated again.
  # Uses ranges to reduce memory consumption.
  # @api private
  class IDAllocator

    # Return a new {IDAllocator}.
    # @return [IDAllocator]
    def initialize
      @allocated_ranges = []
    end

    # Allocate an id.
    # Removes id from the allocator's id space until it is returned.
    # @return [Integer]
    def allocate
      if @allocated_ranges.empty?
        add_leading_range
      elsif @allocated_ranges.first.first == 0
        extend_leading_range
      else
        add_leading_range
      end
    end

    # Return +id+ back to the allocator so it can be allocated again in the future.
    # @note trying to free an unallocated id will cause undefined behavior
    # @return [void]
    def free(id)
      enclosing_range_index = @allocated_ranges.index { |range| range.last >= id && range.first <= id }
      enclosing_range = @allocated_ranges[enclosing_range_index]
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
    end

    private

    # Adds a leading allocated range for the id of 0.
    # If the range is then adjoining with the next, the two will be joined.
    # @return [Integer] the allocated id
    def add_leading_range
      @allocated_ranges.prepend((0..0))
      try_to_join_leading_ranges
      0
    end

    # Expands the first allocated range by adding one id to the end.
    # If the range is then adjoining with the next, the two will be joined.
    # @return [Integer] the allocated id
    def extend_leading_range
      id = @allocated_ranges[0].last.succ
      @allocated_ranges[0] = (@allocated_ranges[0].first..@allocated_ranges[0].last.succ)
      try_to_join_leading_ranges
      id
    end

    # Join the first two ranges if they are adjoining.
    # @return [void]
    def try_to_join_leading_ranges
      if @allocated_ranges[1] && @allocated_ranges[0].last.succ == @allocated_ranges[1].first
        @allocated_ranges[0] = (@allocated_ranges[0].first..@allocated_ranges[1].last)
        @allocated_ranges.delete_at(1)
      end
    end

  end
end
