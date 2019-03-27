require 'sumac'

# make sure it exists
describe Sumac::Messages::Component::Map do

  # should be a subclass of Base
  example do
    expect(Sumac::Messages::Component::Map < Sumac::Messages::Base).to be(true)
  end

  # ::from_object, #properties

  example do
    object = {'a' => 1, 2 => true}
    component = Sumac::Messages::Component::Map.from_object(object)
    expect(component).to be_a(Sumac::Messages::Component::Map)
    properties = { 'object_type' => 'map', 'pairs' => [{ 'key' => { 'object_type' => 'string', 'value' => 'a'}, 'value' => { 'object_type' => 'integer', 'value' => 1}}, { 'key' => { 'object_type' => 'integer', 'value' => 2}, 'value' => { 'object_type' => 'boolean', 'value' => true}}]}
    expect(component.properties).to eq(properties)
  end

  # ::from_properties

  # missing 'pairs' property
  # unexpected property
  example do
    properties = {'object_type' => 'map'}
    expect{ Sumac::Messages::Component::Map.from_properties(properties, 1) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'pairs' property
  example do
    properties = {'object_type' => 'map', 'pairs' => '[]'}
    expect{ Sumac::Messages::Component::Map.from_properties(properties, 1) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'pairs' property subhash
  example do
    properties = {'object_type' => 'map', 'pairs' => [[]]}
    expect{ Sumac::Messages::Component::Map.from_properties(properties, 1) }.to raise_error(Sumac::ProtocolError)
  end

  # missing 'pairs' property subhash key
  example do
    properties = {'object_type' => 'map', 'pairs' => [{ 1 => { 'object_type' => 'string', 'value' => 'a'}, 'value' => { 'object_type' => 'integer', 'value' => 1}}]}
    expect{ Sumac::Messages::Component::Map.from_properties(properties, 1) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'pairs' property subhash value
  example do
    properties = {'object_type' => 'map', 'pairs' => [{ 'key' => 1, 'value' => { 'object_type' => 'integer', 'value' => 1}}]}
    expect{ Sumac::Messages::Component::Map.from_properties(properties, 1) }.to raise_error(Sumac::ProtocolError)
  end

  # not unique 'pairs' keys
  example do
    properties = {'object_type' => 'map', 'pairs' => [{ 'key' => { 'object_type' => 'string', 'value' => 'a'}, 'value' => { 'object_type' => 'integer', 'value' => 1}}, { 'key' => { 'object_type' => 'string', 'value' => 'a'}, 'value' => { 'object_type' => 'integer', 'value' => 1}}]}
    expect{ Sumac::Messages::Component::Map.from_properties(properties, 1) }.to raise_error(Sumac::ProtocolError)
  end

  # all properties present and valid
  example do
    key1_properties = { 'object_type' => 'string', 'value' => 'a'}
    value1_properties = { 'object_type' => 'integer', 'value' => 1}
    key2_properties = { 'object_type' => 'integer', 'value' => 2}
    value2_properties = { 'object_type' => 'boolean', 'value' => true}
    properties = { 'object_type' => 'map', 'pairs' => [{ 'key' => key1_properties, 'value' => value1_properties}, { 'key' => key2_properties, 'value' => value2_properties}]}
    key1_component = instance_double('Sumac::Messages::Component::String')
    expect(Sumac::Messages::Component).to receive(:from_properties).with(key1_properties, 2).and_return(key1_component)
    value1_component = instance_double('Sumac::Messages::Component::Integer')
    expect(Sumac::Messages::Component).to receive(:from_properties).with(value1_properties, 2).and_return(value1_component)
    key2_component = instance_double('Sumac::Messages::Component::Integer')
    expect(Sumac::Messages::Component).to receive(:from_properties).with(key2_properties, 2).and_return(key2_component)
    value2_component = instance_double('Sumac::Messages::Component::Boolean')
    expect(Sumac::Messages::Component).to receive(:from_properties).with(value2_properties, 2).and_return(value2_component)
    component = Sumac::Messages::Component::Map.from_properties(properties, 1)
    expect(component.instance_variable_get(:@pairs)).to eq({key1_component => value1_component, key2_component => value2_component})
    expect(component).to be_a(Sumac::Messages::Component::Map)
  end

  # #object

  # objects found
  example do
    key1_component = instance_double('Sumac::Messages::Component::String')
    value1_component = instance_double('Sumac::Messages::Component::Integer')
    key2_component = instance_double('Sumac::Messages::Component::Integer')
    value2_component = instance_double('Sumac::Messages::Component::Boolean')
    component = Sumac::Messages::Component::Map.new(pairs: {key1_component => value1_component, key2_component => value2_component})
    key1_object = double
    expect(key1_component).to receive(:object).with(no_args).and_return(key1_object)
    value1_object = double
    expect(value1_component).to receive(:object).with(no_args).and_return(value1_object)
    key2_object = double
    expect(key2_component).to receive(:object).with(no_args).and_return(key2_object)
    value2_object = double
    expect(value2_component).to receive(:object).with(no_args).and_return(value2_object)
    object = component.object
    expect(object).to eq({key1_object => value1_object, key2_object => value2_object})
  end

  # ::from_properties, #object
  # integration test: all properties present and valid
  example do
    properties = { 'object_type' => 'map', 'pairs' => [{ 'key' => { 'object_type' => 'string', 'value' => 'a'}, 'value' => { 'object_type' => 'integer', 'value' => 1}}, { 'key' => { 'object_type' => 'integer', 'value' => 2}, 'value' => { 'object_type' => 'boolean', 'value' => true}}]}
    component = Sumac::Messages::Component::Map.from_properties(properties, 1)
    object = component.object
    expect(object).to eq({'a' => 1, 2 => true})
  end

end
