require 'sumac'

# make sure it exists
describe Sumac::Messages::CallRequest do

  # should be a subclass of Message
  example do
    expect(Sumac::Messages::CallRequest < Sumac::Messages::Message).to be(true)
  end

  # ::build, #properties, #to_json

  example do
    object = instance_double('Sumac::Objects::Reference')
    object_component = instance_double('Sumac::Messages::Component::Exposed', :properties => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 1 })
    expect(Sumac::Messages::Component).to receive(:from_object).with(object).and_return(object_component)
    argument1_component = instance_double('Sumac::Messages::Component::Integer', :properties => { 'object_type' => 'integer', 'value' => 2 })
    expect(Sumac::Messages::Component).to receive(:from_object).with(2).and_return(argument1_component)
    argument2_component = instance_double('Sumac::Messages::Component::String', :properties => { 'object_type' => 'string', 'value' => 'abc' })
    expect(Sumac::Messages::Component).to receive(:from_object).with('abc').and_return(argument2_component)
    message = Sumac::Messages::CallRequest.build(id: 0, object: object, method: 'm', arguments: [2, 'abc'])
    expect(message).to be_a(Sumac::Messages::CallRequest)
    expect(JSON.parse(message.to_json)).to eq({ 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 1 }, 'method' => 'm', 'arguments' => [{ 'object_type' => 'integer', 'value' => 2 }, { 'object_type' => 'string', 'value' => 'abc' }] })
  end

  # ::from_properties, #arguments, #object, #id, #method

  # missing or unexpected property
  example do
    properties = { 'message_type' => 'call_request' }
    expect{ Sumac::Messages::CallRequest.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'id' property
  example do
    properties = { 'message_type' => 'call_request', 'id' => '1', 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 1 }, 'method' => 'm', 'arguments' => [] }
    expect{ Sumac::Messages::CallRequest.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'object' property type
  example do
    properties = { 'message_type' => 'call_request', 'id' => 1, 'object' => { 'object_type' => 'null' }, 'method' => 'm', 'arguments' => [] }
    expect{ Sumac::Messages::CallRequest.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'object' property origin
  example do
    properties = { 'message_type' => 'call_request', 'id' => 1, 'object' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 1 }, 'method' => 'm', 'arguments' => [] }
    expect{ Sumac::Messages::CallRequest.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'method' property type
  example do
    properties = { 'message_type' => 'call_request', 'id' => 1, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 1 }, 'method' => 1, 'arguments' => [] }
    expect{ Sumac::Messages::CallRequest.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # 'method' property empty
  example do
    properties = { 'message_type' => 'call_request', 'id' => 1, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 1 }, 'method' => '', 'arguments' => [] }
    expect{ Sumac::Messages::CallRequest.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'arguments' property
  example do
    properties = { 'message_type' => 'call_request', 'id' => 1, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 1 }, 'method' => '', 'arguments' => {} }
    expect{ Sumac::Messages::CallRequest.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # all properties present and valid
  example do
    properties = { 'message_type' => 'call_request', 'id' => 0, 'object' => { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 1 }, 'method' => 'm', 'arguments' => [{ 'object_type' => 'integer', 'value' => 2 }, { 'object_type' => 'string', 'value' => 'abc' }] }
    message = Sumac::Messages::CallRequest.from_properties(properties)
    expect(message).to be_a(Sumac::Messages::CallRequest)
    object = instance_double('Sumac::Messages::Component::Exposed')
    allow_any_instance_of(Sumac::Messages::Component::Exposed).to receive(:object).and_return(object)
    expect(message.arguments).to eq([2,'abc'])
    expect(message.object).to be(object)
    expect(message.id).to eq(0)
    expect(message.method).to eq('m')
  end

end
