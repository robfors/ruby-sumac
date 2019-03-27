require 'sumac'

# make sure it exists
describe Sumac::Messages::Component::Array do

  # should be a subclass of Base
  example do
    expect(Sumac::Messages::Component::Array < Sumac::Messages::Base).to be(true)
  end

  # ::from_object, #properties

  example do
    object = [1]
    component = Sumac::Messages::Component::Array.from_object(object)
    expect(component).to be_a(Sumac::Messages::Component::Array)
    expect(component.properties).to eq({ 'object_type' => 'array', 'elements' => [{ 'object_type' => 'integer', 'value' => 1}]})
  end

  # ::from_properties

  # missing 'elements' property
  # unexpected property
  example do
    properties = {'object_type' => 'array'}
    expect{ Sumac::Messages::Component::Array.from_properties(properties, 1) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'elements' property
  example do
    properties = {'object_type' => 'array', 'elements' => '[]'}
    expect{ Sumac::Messages::Component::Array.from_properties(properties, 1) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'elements' subproperty
  example do
    element_properties = 1
    properties = {'object_type' => 'array', 'elements' => [element_properties]}
    expect(Sumac::Messages::Component).to receive(:from_properties).with(element_properties, 2).and_raise(Sumac::ProtocolError)
    expect{ Sumac::Messages::Component::Array.from_properties(properties, 1) }.to raise_error(Sumac::ProtocolError)
  end

  # all properties present and valid
  example do
    element1_properties = { 'object_type' => 'integer', 'value' => 1}
    element2_properties = { 'object_type' => 'boolean', 'value' => false}
    properties = {'object_type' => 'array', 'elements' => [element1_properties, element2_properties]}
    element1_component = instance_double('Sumac::Messages::Component::Integer')
    expect(Sumac::Messages::Component).to receive(:from_properties).with(element1_properties, 2).and_return(element1_component)
    element2_component = instance_double('Sumac::Messages::Component::Boolean')
    expect(Sumac::Messages::Component).to receive(:from_properties).with(element2_properties, 2).and_return(element2_component)
    component = Sumac::Messages::Component::Array.from_properties(properties, 1)
    expect(component.instance_variable_get(:@elements)).to eq([element1_component, element2_component])
    expect(component).to be_a(Sumac::Messages::Component::Array)
  end

  # #object

  # object found
  example do
    element1_component = instance_double('Sumac::Messages::Component::Integer')
    element2_component = instance_double('Sumac::Messages::Component::Boolean')
    component = Sumac::Messages::Component::Array.new(elements: [element1_component, element2_component])
    element1_object = double
    expect(element1_component).to receive(:object).with(no_args).and_return(element1_object)
    element2_object = double
    expect(element2_component).to receive(:object).with(no_args).and_return(element2_object)
    expect(component.object).to eq([element1_object, element2_object])
  end

  # ::from_properties, #object
  # integration test: all properties present and valid
  example do
    properties = {'object_type' => 'array', 'elements' => [{ 'object_type' => 'integer', 'value' => 1}]}
    component = Sumac::Messages::Component::Array.from_properties(properties, 1)
    object = component.object
    expect(object).to eq([1])
  end

end
