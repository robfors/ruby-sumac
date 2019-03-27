require 'sumac'

# make sure it exists
describe Sumac::Messages::Component::Exposed do

  # should be a subclass of Base
  example do
    expect(Sumac::Messages::Component::Exposed < Sumac::Messages::Base).to be(true)
  end

  # ::from_object, #properties

  # local object
  example do
    object = instance_double('Sumac::Objects::LocalReference')
    expect(object).to receive(:origin).with(no_args).and_return(:local)
    expect(object).to receive(:id).with(no_args).and_return(1)
    component = Sumac::Messages::Component::Exposed.from_object(object)
    expect(component).to be_a(Sumac::Messages::Component::Exposed)
    expect(component.properties).to eq({ 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 1 })
  end

  # remote object
  example do
    object = instance_double('Sumac::Objects::RemoteReference')
    expect(object).to receive(:origin).with(no_args).and_return(:remote)
    expect(object).to receive(:id).with(no_args).and_return(1)
    component = Sumac::Messages::Component::Exposed.from_object(object)
    expect(component).to be_a(Sumac::Messages::Component::Exposed)
    expect(component.properties).to eq({ 'object_type' => 'exposed', 'origin' => 'local', 'id' => 1 })
  end

  # ::from_properties, #object

  # missing 'origin' property
  # unexpected property
  example do
    properties = { 'object_type' => 'exposed', 'id' => 1 }
    expect{ Sumac::Messages::Component::Exposed.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'origin' property
  example do
    properties = { 'object_type' => 'exposed', 'origin' => 'locals', 'id' => 1 }
    expect{ Sumac::Messages::Component::Exposed.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # missing 'id' property
  example do
    properties = { 'object_type' => 'exposed', 'origin' => 'local' }
    expect{ Sumac::Messages::Component::Exposed.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'id' property
  example do
    properties = { 'object_type' => 'exposed', 'origin' => 'local', 'id' => '1' }
    expect{ Sumac::Messages::Component::Exposed.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  example do
    properties = { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 1 }
    component = Sumac::Messages::Component::Exposed.from_properties(properties)
    expect(component).to be_a(Sumac::Messages::Component::Exposed)
    expect(component.object).to be(component)
  end

  # #id
  example do
    properties = { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 1 }
    component = Sumac::Messages::Component::Exposed.from_properties(properties)
    expect(component.id).to eq(1)
  end

  # #origin
  example do
    properties = { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 1 }
    component = Sumac::Messages::Component::Exposed.from_properties(properties)
    expect(component.origin).to eq(:local)
  end

end
