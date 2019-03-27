require 'sumac'

# make sure it exists
describe Sumac::Closer do

  def build_closer
    connection = instance_double('Sumac::Connection')
    complete_future = instance_double('QuackConcurrency::Future')
    allow(QuackConcurrency::Future).to receive(:new).and_return(complete_future)
    initiate_future = instance_double('QuackConcurrency::Future')
    allow(QuackConcurrency::Future).to receive(:new).and_return(initiate_future)
    closer = Sumac::Closer.new(connection)
  end

  # ::new
  example do
    connection = instance_double('Sumac::Connection')
    complete_future = instance_double('QuackConcurrency::Future')
    expect(QuackConcurrency::Future).to receive(:new).with(no_args).and_return(complete_future)
    initiate_future = instance_double('QuackConcurrency::Future')
    expect(QuackConcurrency::Future).to receive(:new).with(no_args).and_return(initiate_future)
    closer = Sumac::Closer.new(connection)
    expect(closer.instance_variable_get(:@connection)).to be(connection)
    expect(closer.instance_variable_get(:@complete_future)).to be(complete_future)
    expect(closer.instance_variable_get(:@initiate_future)).to be(initiate_future)
    expect(closer.instance_variable_get(:@killed)).to be(false)
    expect(closer).to be_a(Sumac::Closer)
  end

  # #closed
  example do
    closer = build_closer
    complete_future = closer.instance_variable_get(:@complete_future)
    expect(complete_future).to receive(:set).with(no_args)
    closer.closed
  end

  # #closed?
  example do
    closer = build_closer
    complete_future = closer.instance_variable_get(:@complete_future)
    expect(complete_future).to receive(:complete?).with(no_args).and_return(false)
    expect(closer.closed?).to be(false)
  end

  # #enable
  example do
    closer = build_closer
    initiate_future = closer.instance_variable_get(:@initiate_future)
    expect(initiate_future).to receive(:set).with(no_args)
    closer.enable
  end

  # #join
  example do
    closer = build_closer
    complete_future = closer.instance_variable_get(:@complete_future)
    expect(complete_future).to receive(:get).with(no_args)
    closer.join
  end

  # #killed
  example do
    closer = build_closer
    closer.instance_variable_set(:@killed, false)
    closer.killed
    expect(closer.instance_variable_get(:@killed)).to be(true)
  end

  # #killed?
  example do
    closer = build_closer
    closer.instance_variable_set(:@killed, true)
    expect(closer.killed?).to be(true)
  end

  # #wait_until_enabled
  example do
    closer = build_closer
    initiate_future = closer.instance_variable_get(:@initiate_future)
    expect(initiate_future).to receive(:get).with(no_args)
    closer.wait_until_enabled
  end

end
