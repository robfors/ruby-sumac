require 'sumac'

# make sure it exists
describe Sumac::RemoteEntry do

  def build_remote_entry
    future = instance_double('QuackConcurrency::Future')
    allow(QuackConcurrency::Future).to receive(:new).and_return(future)
    remote_entry = Sumac::RemoteEntry.new
  end

  # ::new
  example do
    future = instance_double('QuackConcurrency::Future')
    allow(QuackConcurrency::Future).to receive(:new).with(no_args).and_return(future)
    remote_entry = Sumac::RemoteEntry.new
    expect(remote_entry.instance_variable_get(:@future)).to be(future)
    expect(remote_entry).to be_a(Sumac::RemoteEntry)
  end

  # #cancel
  example do
    remote_entry = build_remote_entry
    future = remote_entry.instance_variable_get(:@future)
    expect(future).to receive(:raise).with(Sumac::ClosedObjectRequestBrokerError)
    remote_entry.cancel
  end

  # #get
  example do
    remote_entry = build_remote_entry
    future = remote_entry.instance_variable_get(:@future)
    value = double
    expect(future).to receive(:get).with(no_args).and_return(value)
    expect(remote_entry.get).to be(value)
  end

  # #set
  example do
    remote_entry = build_remote_entry
    value = double
    future = remote_entry.instance_variable_get(:@future)
    expect(future).to receive(:set).with(value)
    remote_entry.set(value)
  end

end
