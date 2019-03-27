require 'sumac'

# make sure it exists
describe Sumac::RemoteObject do

  # remote object should be an ExposedObject
  example do
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    reference = instance_double('Sumac::Objects::RemoteReference')
    object = Sumac::RemoteObject.new(object_request_broker, reference)
    expect(object).to be_a(Sumac::ExposedObject)
  end

  def build_remote_object
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    reference = instance_double('Sumac::Objects::RemoteReference')
    object = Sumac::RemoteObject.new(object_request_broker, reference)
  end

  # ::get_reference
  example do
    reference = instance_double('Sumac::Objects::RemoteReference')
    object = instance_double('Sumac::RemoteObject')
    expect(object).to receive(:_sumac_remote_reference).with(no_args).and_return(reference)
    expect(Sumac::RemoteObject.get_reference(object)).to be(reference)
  end

  # ::remote_object?

  # not a remote object
  example do
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    object = instance_double('Sumac::RemoteObject')
    expect(object).to receive(:is_a?).with(Sumac::RemoteObject).and_return(false)
    expect(Sumac::RemoteObject.remote_object?(object_request_broker, object)).to be(false)
  end

  # is a remote object, from another broker
  example do
    object_request_broker1 = instance_double('Sumac::ObjectRequestBroker')
    object_request_broker2 = instance_double('Sumac::ObjectRequestBroker')
    reference = instance_double('Sumac::Objects::RemoteReference')
    object = instance_double('Sumac::RemoteObject')
    expect(object).to receive(:is_a?).with(Sumac::RemoteObject).and_return(true)
    expect(object).to receive(:_sumac_object_request_broker).with(no_args).and_return(object_request_broker2)
    expect(Sumac::RemoteObject.remote_object?(object_request_broker1, object)).to be(false)
  end

  # is a remote object, from same connection
  example do
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    reference = instance_double('Sumac::Objects::RemoteReference')
    object = instance_double('Sumac::RemoteObject')
    expect(object).to receive(:is_a?).with(Sumac::RemoteObject).and_return(true)
    expect(object).to receive(:_sumac_object_request_broker).with(no_args).and_return(object_request_broker)
    expect(Sumac::RemoteObject.remote_object?(object_request_broker, object)).to be(true)
  end

  # ::new
  example do
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    reference = instance_double('Sumac::Objects::RemoteReference')
    object = Sumac::RemoteObject.new(object_request_broker, reference)
    expect(object.instance_variable_get(:@object_request_broker)).to be(object_request_broker)
    expect(object.instance_variable_get(:@reference)).to be(reference)
    expect(object).to be_a(Sumac::RemoteObject)
  end

  # #forget
  example do
    object = build_remote_object
    object_request_broker = object.instance_variable_get(:@object_request_broker)
    expect(object_request_broker).to receive(:forget).with(object).and_return(nil)
    object.forget
  end

  # #inspect
  example do
    object = build_remote_object
    expect(object).to receive(:__id__).with(no_args).and_return(1234)
    reference = object.instance_variable_get(:@reference)
    expect(reference).to receive(:id).with(no_args).and_return(0)
    expect(object.inspect).to eq('#<Sumac::RemoteObject:0x009a4 id:0 >')
  end

  # #method_missing

  # stale
  example do
    object = build_remote_object
    object_request_broker = object.instance_variable_get(:@object_request_broker)
    expect(object_request_broker).to receive(:call).with({object: object, method: 'm', arguments: [1,:b]}).and_raise(Sumac::ClosedObjectRequestBrokerError)
    expect{ object.m(1, :b) }.to raise_error(Sumac::StaleObjectError)
  end

  # active
  example do
    object = build_remote_object
    object_request_broker = object.instance_variable_get(:@object_request_broker)
    return_value = double
    expect(object_request_broker).to receive(:call).with({object: object, method: 'm', arguments: [1,:b]}).and_return(return_value)
    expect(object.m(1, :b)).to eq(return_value)
  end

  # #object_request_broker
  example do
    object = build_remote_object
    expect(object.object_request_broker).to be(object.instance_variable_get(:@object_request_broker))
  end

  # #receivable?
  example do
    object = build_remote_object
    object_request_broker = object.instance_variable_get(:@object_request_broker)
    expect(object_request_broker).to receive(:receivable?).with(object).and_return(true)
    expect(object.receivable?).to be(true)
  end

  # #sendable?
  example do
    object = build_remote_object
    object_request_broker = object.instance_variable_get(:@object_request_broker)
    expect(object_request_broker).to receive(:sendable?).with(object).and_return(true)
    expect(object.sendable?).to be(true)
  end

  # #stale?
  example do
    object = build_remote_object
    object_request_broker = object.instance_variable_get(:@object_request_broker)
    expect(object_request_broker).to receive(:stale?).with(object).and_return(true)
    expect(object.stale?).to be(true)
  end

  # #_sumac_object_request_broker
  example do
    object = build_remote_object
    expect(object._sumac_object_request_broker).to be(object.instance_variable_get(:@object_request_broker))
  end

  # #_sumac_remote_reference
  example do
    object = build_remote_object
    expect(object._sumac_remote_reference).to be(object.instance_variable_get(:@reference))
  end

end
