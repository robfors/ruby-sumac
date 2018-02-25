class TestIDAllocator < Test::Unit::TestCase
  
  
  def setup
    
  end
  
  
  def teardown
    ## Nothing really
  end
  
  
  def test
    allocator = Sumac::IDAllocator.new
    assert_equal(allocator.allocate, 0)
    assert_equal(allocator.allocate, 1)
    assert_equal(allocator.allocate(5), 5)
    #assert_not_equal(allocator.allocate(0), 0)
    assert_equal(allocator.free(0), nil)
    assert_equal(allocator.allocate, 0)
  end
  
  
end
