require 'sumac'

# make sure it exists
describe Sumac::Messages::Forget do

  # should be a subclass of Message
  example do
    expect(Sumac::Messages::Forget < Sumac::Messages::Message).to be(true)
  end

  # ::build
  example do
    object = instance_double('Sumac::Objects::LocalReference')
    exposed_component = instance_double('Sumac::Messages::Component::Exposed')
    expect(Sumac::Messages::Component::Exposed).to receive(:from_object).with(object).and_return(exposed_component)
    message = Sumac::Messages::Forget.build(object: object)
    expect(message).to be_a(Sumac::Messages::Forget)
    expect(message.instance_variable_get(:@object)).to be(exposed_component)
  end

  # #properties, #to_json
  example do
    exposed_component = instance_double('Sumac::Messages::Component::Exposed')
    message = Sumac::Messages::Forget.new(object: exposed_component)
    expect(exposed_component).to receive(:properties).with(no_args).and_return({ 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 1 })
    expect(JSON.parse(message.to_json)).to eq({ 'message_type' => 'forget', 'object' => { 'object_type' => 'exposed', 'origin' => 'remote', 'id' => 1 } })
  end

  # ::from_properties

  # missing or unexpected property
  example do
    properties = { 'message_type' => 'forget' }
    expect{ Sumac::Messages::Forget.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'object' property
  example do
    object_properties = { 'object_type' => 'integer', 'value' => 1 }
    properties = { 'message_type' => 'forget', 'object' => object_properties }
    integer_component = instance_double('Sumac::Messages::Component::Integer')
    expect(Sumac::Messages::Component).to receive(:from_properties).with(object_properties).and_return(integer_component)
    expect(integer_component).to receive(:is_a?).with(Sumac::Messages::Component::Exposed).and_return(false)
    expect{ Sumac::Messages::Forget.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # all properties present and valid
  example do
    object_properties = { 'object_type' => 'exposed', 'origin' => 'local', 'id' => 1 }
    properties = { 'message_type' => 'forget', 'object' => object_properties }
    exposed_component = instance_double('Sumac::Messages::Component::Exposed')
    expect(Sumac::Messages::Component).to receive(:from_properties).with(object_properties).and_return(exposed_component)
    expect(exposed_component).to receive(:is_a?).with(Sumac::Messages::Component::Exposed).and_return(true)
    message = Sumac::Messages::Forget.from_properties(properties)
    expect(message).to be_a(Sumac::Messages::Forget)
    expect(message.instance_variable_get(:@object)).to be(exposed_component)
  end

  # #object
  example do
    exposed_component = instance_double('Sumac::Messages::Component::Exposed')
    message = Sumac::Messages::Forget.new(object: exposed_component)
    expect(exposed_component).to receive(:object).with(no_args).and_return(exposed_component)
    expect(message.object).to be(exposed_component)
  end

end
