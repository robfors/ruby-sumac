require 'sumac'

# make sure it exists
describe Sumac::Objects::RemoteReference do

  def build_remote_reference
    connection = instance_double('Sumac::Connection')
    id = 0
    scheduler = instance_double('Sumac::Objects::Reference::Scheduler')
    allow(Sumac::Objects::Reference::Scheduler).to receive(:new).and_return(scheduler)
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    allow(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    object = double
    allow(Sumac::RemoteObject).to receive(:new).and_return(object)
    reference = Sumac::Objects::RemoteReference.new(connection, id: id, tentative: true)
  end

  # should be a subclass of Reference
  example do
    expect(Sumac::Objects::RemoteReference < Sumac::Objects::Reference).to be(true)
  end

  # #new

  # tentative
  example do
    connection = instance_double('Sumac::Connection')
    id = 0
    scheduler = instance_double('Sumac::Objects::Reference::Scheduler')
    allow(Sumac::Objects::Reference::Scheduler).to receive(:new).and_return(scheduler)
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    object = double
    allow(Sumac::RemoteObject).to receive(:new).and_return(object)
    reference = Sumac::Objects::RemoteReference.new(connection, id: id, tentative: true)
    expect(Sumac::Objects::Reference::Scheduler).to have_received(:new).with(reference, tentative: true)
    expect(Sumac::RemoteObject).to have_received(:new).with(object_request_broker, reference)
    expect(reference.instance_variable_get(:@object)).to be(object)
    expect(reference).to be_a(Sumac::Objects::RemoteReference)
  end

  example do
    connection = instance_double('Sumac::Connection')
    id = 0
    scheduler = instance_double('Sumac::Objects::Reference::Scheduler')
    allow(Sumac::Objects::Reference::Scheduler).to receive(:new).and_return(scheduler)
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    object = double
    allow(Sumac::RemoteObject).to receive(:new).and_return(object)
    reference = Sumac::Objects::RemoteReference.new(connection, id: id, tentative: false)
    expect(Sumac::Objects::Reference::Scheduler).to have_received(:new).with(reference, tentative: false)
    expect(Sumac::RemoteObject).to have_received(:new).with(object_request_broker, reference)
    expect(reference.instance_variable_get(:@object)).to be(object)
    expect(reference).to be_a(Sumac::Objects::RemoteReference)
  end

  # #origin
  example do
    reference = build_remote_reference
    expect(reference.origin).to eq(:remote)
  end

end
