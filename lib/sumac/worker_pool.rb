class Sumac
  class WorkerPool
  
    def initialize(size = 1, duck_types: {})
      raise 'Error: worker count invalid' if size < 1
      @thread_class = duck_types[:thread] || Thread
      @semaphore = QuackConcurrency::Semaphore.new(size)
      @threads = []
    end
    
    def size
      @semaphore.permit_count
    end
    
    def size=(new_size)
      @semaphore.set_permit_count!(new_size)
    end
    
    def run(&block)
      @semaphore.acquire
      @threads << @thread_class.new do
        block.call
        @threads.delete(@thread_class.current)
        @semaphore.release
      end
    end
    
    def join
      @threads.each(&:join)
    end
    
  end
end
