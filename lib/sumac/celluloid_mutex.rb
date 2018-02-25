require 'celluloid'

class CelluloidMutex

  def initialize
    @mutex = Mutex.new
    @locked = false
    @waiting_list = []
  end
  
  def lock
    @mutex.synchronize do
      if @locked
        future = Celluloid::Future.new
        @waiting_list.push(future)
        @mutex.unlock
        future.value
        @mutex.lock
      else
        @locked = true
      end
    end
    nil
  end
  
  def locked?
    @mutex.synchronize { @locked }
  end
  
  def synchronize
    lock
    result = yield
    result
  ensure
    unlock
  end
  
  def unlock
    @mutex.synchronize do
      if @locked
        @locked = false
        if @waiting_list.any?
          future = @waiting_list.shift
          future.signal
        end
      else
       raise "mutex not locked"
      end
    end
    nil
  end
  
end
