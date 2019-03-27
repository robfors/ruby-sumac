require 'sumac'

# make sure it exists
describe Sumac::Messages::Component::Integer do

  # should be a subclass of Base
  example do
    expect(Sumac::Messages::Component::Integer < Sumac::Messages::Base).to be(true)
  end

  # ::from_object, #properties

  example do
    object = 1
    component = Sumac::Messages::Component::Integer.from_object(object)
    expect(component).to be_a(Sumac::Messages::Component::Integer)
    expect(component.properties).to eq({ 'object_type' => 'integer', 'value' => 1})
  end

  # ::from_properties, #object

  # missing 'value' property
  # unexpected property
  example do
    properties = {'object_type' => 'integer'}
    expect{ Sumac::Messages::Component::Integer.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'value' property
  example do
    properties = {'object_type' => 'integer', 'value' => '1'}
    expect{ Sumac::Messages::Component::Integer.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # all properties present and valid
  example do
    properties = {'object_type' => 'integer', 'value' => 1}
    component = Sumac::Messages::Component::Integer.from_properties(properties)
    expect(component).to be_a(Sumac::Messages::Component::Integer)
    value = component.object
    expect(value).to eq(1)
  end

end
