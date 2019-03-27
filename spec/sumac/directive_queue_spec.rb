require 'sumac'

# make sure it exists
describe Sumac::DirectiveQueue do

  # ::new
  example do
    directive_queue = Sumac::DirectiveQueue.new
    expect(directive_queue.instance_variable_get(:@active_thread)).to be(false)
    expect(directive_queue.instance_variable_get(:@waiting_threads)).to eq([])
    expect(directive_queue).to be_a(Sumac::DirectiveQueue)
  end

  # #execute

  # return value
  example do
    directive_queue = Sumac::DirectiveQueue.new
    value = double
    expect(directive_queue.execute { value }).to be(value)
  end

  # a few threads, not concurrent
  example do
    directive_queue = Sumac::DirectiveQueue.new
    thread1 = Thread.new do
      directive_queue.execute {}
    end
    thread2 = Thread.new do
      sleep 1
      directive_queue.execute {}
    end
    sleep 2
    expect(thread1.alive?).to be(false)
    expect(thread2.alive?).to be(false)
    directive_queue.execute {}
  end

  # two threads, concurrent
  # make sure they dont run at the same time
  example do
    directive_queue = Sumac::DirectiveQueue.new
    thread1 = Thread.new do
      directive_queue.execute { sleep 3 }
    end
    thread2 = Thread.new do
      sleep 1
      directive_queue.execute { sleep 2 }
    end
    sleep 2
    expect(thread1.alive?).to be(true)
    expect(thread2.alive?).to be(true)
    sleep 2
    expect(thread1.alive?).to be(false)
    expect(thread2.alive?).to be(true)
    sleep 2
    expect(thread1.alive?).to be(false)
    expect(thread2.alive?).to be(false)
    directive_queue.execute {}
  end

  # three threads, concurrent
  # make sure they run in order
  example do
    directive_queue = Sumac::DirectiveQueue.new
    log = []
    thread1 = Thread.new do
      directive_queue.execute { sleep 3; log << 1 }
    end
    thread2 = Thread.new do
      sleep 2
      directive_queue.execute { sleep 2; log << 2 }
    end
    thread3 = Thread.new do
      sleep 1
      directive_queue.execute { sleep 2; log << 3 }
    end
    [thread1, thread2, thread3].each(&:join)
    expect(log).to eq([1,3,2])
  end

  # two threads
  # make sure a raised error is tolerated
  example do
    directive_queue = Sumac::DirectiveQueue.new
    thread1 = Thread.new do
      directive_queue.execute { sleep 3; raise StandardError } rescue nil
    end
    thread2 = Thread.new do
      sleep 1
      directive_queue.execute { sleep 2; raise StandardError } rescue nil
    end
    sleep 2
    expect(thread1.alive?).to be(true)
    expect(thread2.alive?).to be(true)
    sleep 2
    expect(thread1.alive?).to be(false)
    expect(thread2.alive?).to be(true)
    sleep 2
    expect(thread1.alive?).to be(false)
    expect(thread2.alive?).to be(false)
    directive_queue.execute {}
  end

  # #execute_next
  
  # return value
  example do
    directive_queue = Sumac::DirectiveQueue.new
    value = double
    expect(directive_queue.execute_next { value }).to be(value)
  end

  # a few threads, not concurrent
  example do
    directive_queue = Sumac::DirectiveQueue.new
    thread1 = Thread.new do
      directive_queue.execute_next {}
    end
    thread2 = Thread.new do
      sleep 1
      directive_queue.execute_next {}
    end
    sleep 2
    expect(thread1.alive?).to be(false)
    expect(thread2.alive?).to be(false)
    directive_queue.execute_next {}
  end

  # two threads, concurrent
  # make sure they dont run at the same time
  example do
    directive_queue = Sumac::DirectiveQueue.new
    thread1 = Thread.new do
      directive_queue.execute_next { sleep 3 }
    end
    thread2 = Thread.new do
      sleep 1
      directive_queue.execute_next { sleep 2 }
    end
    sleep 2
    expect(thread1.alive?).to be(true)
    expect(thread2.alive?).to be(true)
    sleep 2
    expect(thread1.alive?).to be(false)
    expect(thread2.alive?).to be(true)
    sleep 2
    expect(thread1.alive?).to be(false)
    expect(thread2.alive?).to be(false)
    directive_queue.execute_next {}
  end

  # three threads, concurrent
  # make sure they run in order
  example do
    directive_queue = Sumac::DirectiveQueue.new
    log = []
    thread1 = Thread.new do
      directive_queue.execute_next { sleep 3; log << 1 }
    end
    thread2 = Thread.new do
      sleep 2
      directive_queue.execute_next { sleep 2; log << 2 }
    end
    thread3 = Thread.new do
      sleep 1
      directive_queue.execute_next { sleep 2; log << 3 }
    end
    [thread1, thread2, thread3].each(&:join)
    expect(log).to eq([1,2,3])
  end

  # three threads, concurrent
  # make sure they run in order with a higher priority than #execute
  example do
    directive_queue = Sumac::DirectiveQueue.new
    log = []
    thread1 = Thread.new do
      directive_queue.execute { sleep 3; log << 1 }
    end
    thread2 = Thread.new do
      sleep 2
      directive_queue.execute_next { sleep 2; log << 2 }
    end
    thread3 = Thread.new do
      sleep 1
      directive_queue.execute { sleep 2; log << 3 }
    end
    [thread1, thread2, thread3].each(&:join)
    expect(log).to eq([1,2,3])
  end

  # two threads
  # make sure a raised error is tolerated
  example do
    directive_queue = Sumac::DirectiveQueue.new
    thread1 = Thread.new do
      directive_queue.execute_next { sleep 3; raise StandardError } rescue nil
    end
    thread2 = Thread.new do
      sleep 1
      directive_queue.execute_next { sleep 2; raise StandardError } rescue nil
    end
    sleep 2
    expect(thread1.alive?).to be(true)
    expect(thread2.alive?).to be(true)
    sleep 2
    expect(thread1.alive?).to be(false)
    expect(thread2.alive?).to be(true)
    sleep 2
    expect(thread1.alive?).to be(false)
    expect(thread2.alive?).to be(false)
    directive_queue.execute_next {}
  end

end
