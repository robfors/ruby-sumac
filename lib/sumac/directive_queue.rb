module Sumac

  # Restricts events directed to {Connection} to execute one at a time.
  # Uses a +Mutex+ to block a thread when an event is already being processed. 
  # @api private
  class DirectiveQueue

    # Build a new {DirectiveQueue}.
    # @return [DirectiveQueue]
    def initialize
      @active_thread = false
      @mutex = Mutex.new
      @waiting_threads = []
    end

    # Execute a block soon.
    # If no other thread is executing a block, the block will be executed immediately.
    # If another thread is executing a block, add the thread to the back of the queue and executes
    # the block when permitted.
    # @yield [] executed when permitted
    # @raise [Exception] anything raised in block
    # @return [Object] return value from block
    def execute(&block)
      @mutex.synchronize do
        if @active_thread
          condition_variable = ConditionVariable.new
          @waiting_threads.push(condition_variable)
          condition_variable.wait(@mutex)
        end
        @active_thread = true
      end
      return_value = yield
    ensure
      @mutex.synchronize do
        @active_thread = false
        next_waiting_thread = @waiting_threads.shift
        next_waiting_thread&.signal
      end
    end

    # Execute a block next.
    # If no other thread is executing a block, the block will be executed immediately.
    # If another thread is executing a block, add the thread to the front of the queue and executes
    # the block when the current thread has finished its block.
    # @note if multiple threads are queued via this method their order is undefined
    # @yield [] executed when permitted
    # @raise [Exception] anything raised in block
    # @return [Object] return value from block
    def execute_next(&block)
      @mutex.synchronize do
        if @active_thread
          condition_variable = ConditionVariable.new
          @waiting_threads.unshift(condition_variable)
          condition_variable.wait(@mutex)
        end
        @active_thread = true
      end
      return_value = yield
    ensure
      @mutex.synchronize do
        @active_thread = false
        next_waiting_thread = @waiting_threads.shift
        next_waiting_thread&.signal
      end
    end

  end

end
