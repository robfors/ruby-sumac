require 'sumac'

# make sure it exists
describe Sumac::Objects::LocalReference do

  def build_local_reference
    connection = instance_double('Sumac::Connection')
    object = double
    id = 0
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    expect(Sumac::LocalObject).to receive(:set_reference)
    reference = Sumac::Objects::LocalReference.new(connection, id: id, object: object)
  end

  # should be a subclass of Reference
  example do
    expect(Sumac::Objects::LocalReference < Sumac::Objects::Reference).to be(true)
  end

  # #new

  # tentative
  example do
    connection = instance_double('Sumac::Connection')
    id = 0
    object = double
    scheduler = instance_double('Sumac::Objects::Reference::Scheduler')
    allow(Sumac::Objects::Reference::Scheduler).to receive(:new).and_return(scheduler)
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    allow(Sumac::LocalObject).to receive(:set_reference)
    reference = Sumac::Objects::LocalReference.new(connection, id: id, object: object, tentative: true)
    expect(Sumac::Objects::Reference::Scheduler).to have_received(:new).with(reference, tentative: true)
    expect(Sumac::LocalObject).to have_received(:set_reference).with(object_request_broker, object, reference)
    expect(reference).to be_a(Sumac::Objects::LocalReference)
    expect(reference.instance_variable_get(:@object)).to be(object)
  end

  example do
    connection = instance_double('Sumac::Connection')
    id = 0
    object = double
    scheduler = instance_double('Sumac::Objects::Reference::Scheduler')
    allow(Sumac::Objects::Reference::Scheduler).to receive(:new).and_return(scheduler)
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    allow(Sumac::LocalObject).to receive(:set_reference)
    reference = Sumac::Objects::LocalReference.new(connection, id: id, object: object, tentative: false)
    expect(Sumac::Objects::Reference::Scheduler).to have_received(:new).with(reference, tentative: false)
    expect(Sumac::LocalObject).to have_received(:set_reference).with(object_request_broker, object, reference)
    expect(reference.instance_variable_get(:@object)).to be(object)
    expect(reference).to be_a(Sumac::Objects::LocalReference)
  end

  # #no_longer_sendable
  example do
    reference = build_local_reference
    connection = reference.instance_variable_get(:@connection)
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    object = reference.instance_variable_get(:@object)
    expect(Sumac::LocalObject).to receive(:clear_reference).with(object_request_broker, object)
    reference.no_longer_sendable
  end

  # #origin
  example do
    reference = build_local_reference
    expect(reference.origin).to eq(:local)
  end

end
