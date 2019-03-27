require 'sumac'

# make sure it exists
describe Sumac::IDAllocator do

  # ::new
  example do
    id_allocator = Sumac::IDAllocator.new
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([])
    expect(id_allocator).to be_a(Sumac::IDAllocator)
  end

  # #allocate

  # no allocated ranges
  example do
    id_allocator = Sumac::IDAllocator.new
    expect(id_allocator).to receive(:add_leading_range).with(no_args).and_return(0)
    expect(id_allocator.allocate).to eq(0)
  end

  # first allocated range covers 0
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.instance_variable_set(:@allocated_ranges, [(0..2)])
    expect(id_allocator).to receive(:extend_leading_range).with(no_args).and_return(3)
    expect(id_allocator.allocate).to eq(3)
  end

  # else
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.instance_variable_set(:@allocated_ranges, [(2..4)])
    expect(id_allocator).to receive(:add_leading_range).with(no_args).and_return(0)
    expect(id_allocator.allocate).to eq(0)
  end

  # integration test: when called when no ids are allocated it should return 0
  example do
    id_allocator = Sumac::IDAllocator.new
    expect(id_allocator.allocate).to eq(0)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..0)])
  end

  # integration test: when called when 0 is allocated it should return 1
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.allocate
    expect(id_allocator.allocate).to be(1)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..1)])
  end

  # integration test: when called when 0,2 is allocated it should return 1 then 3
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.allocate
    id_allocator.allocate
    id_allocator.allocate
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..2)])
    id_allocator.free(1)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..0), (2..2)])
    expect(id_allocator.allocate).to be(1)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..2)])
    expect(id_allocator.allocate).to be(3)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..3)])
  end

  # integration test: when called when 0 is allocated then freed it should return 0
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.allocate
    id_allocator.free(0)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq []
    expect(id_allocator.allocate).to be(0)
  end

  # integration test: when called when 1 is allocated it should return 0
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.allocate
    id_allocator.allocate
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..1)])
    id_allocator.free(0)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(1..1)])
    expect(id_allocator.allocate).to be(0)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..1)])
  end

  # #free

  # enclosing range has size of 1
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.instance_variable_set(:@allocated_ranges, [(0..0), (2..2), (4..5)])
    id_allocator.free(2)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..0), (4..5)])
  end

  # enclosing range starts at the id
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.instance_variable_set(:@allocated_ranges, [(0..0), (2..5), (7..8)])
    id_allocator.free(2)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..0), (3..5), (7..8)])
  end

  # enclosing range ends at the id
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.instance_variable_set(:@allocated_ranges, [(0..0), (2..5), (7..8)])
    id_allocator.free(5)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..0), (2..4), (7..8)])
  end

  # else (id within the non-inclusive bounds of enclosing range)
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.instance_variable_set(:@allocated_ranges, [(0..0), (2..5), (7..8)])
    id_allocator.free(3)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..0), (2..2), (4..5), (7..8)])
  end

  # integration test: when called with 0 when 0 is allocated should not raise error
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.allocate
    expect{ id_allocator.free(0) }.not_to raise_error
  end

  # integration test: when called with 2 when 2 is allocated it should not raise error
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.instance_variable_set(:@allocated_ranges, [(2..2)])
    expect{ id_allocator.free(2) }.not_to raise_error
  end

  # integration test: when called with 2 when 2,3 is allocated it should not raise error
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.instance_variable_set(:@allocated_ranges, [(2..3)])
    expect{ id_allocator.free(2) }.not_to raise_error
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(3..3)])
  end

  # integration test: when called with 2 when 1,2 is allocated it should not raise error
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.instance_variable_set(:@allocated_ranges, [(1..2)])
    expect{ id_allocator.free(2) }.not_to raise_error
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(1..1)])
  end

  # integration test: when called with 2 when 1,2,3 is allocated it should not raise error
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.instance_variable_set(:@allocated_ranges, [(1..3)])
    expect{ id_allocator.free(2) }.not_to raise_error
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(1..1), (3..3)])
  end

  # #add_leading_range
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.instance_variable_set(:@allocated_ranges, [])
    expect(id_allocator).to receive(:try_to_join_leading_ranges).with(no_args)
    expect(id_allocator.send(:add_leading_range)).to eq(0)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..0)])
  end

  # #extend_leading_range
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.instance_variable_set(:@allocated_ranges, [(0..2)])
    expect(id_allocator).to receive(:try_to_join_leading_ranges).with(no_args)
    expect(id_allocator.send(:extend_leading_range)).to eq(3)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..3)])
  end

  # #try_to_join_leading_ranges
  
  # ranges not adjoining
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.instance_variable_set(:@allocated_ranges, [(0..2), (4..5)])
    id_allocator.send(:try_to_join_leading_ranges)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..2), (4..5)])
  end

  # ranges adjoining
  example do
    id_allocator = Sumac::IDAllocator.new
    id_allocator.instance_variable_set(:@allocated_ranges, [(0..2), (3..5)])
    id_allocator.send(:try_to_join_leading_ranges)
    expect(id_allocator.instance_variable_get(:@allocated_ranges)).to eq([(0..5)])
  end

end
