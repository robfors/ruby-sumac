require 'sumac'

# make sure it exists
describe Sumac::Messages::Component::String do

  # should be a subclass of Base
  example do
    expect(Sumac::Messages::Component::String < Sumac::Messages::Base).to be(true)
  end

  # ::from_object, #properties

  example do
    object = 'abc'
    component = Sumac::Messages::Component::String.from_object(object)
    expect(component).to be_a(Sumac::Messages::Component::String)
    expect(component.properties).to eq({ 'object_type' => 'string', 'value' => 'abc'})
  end

  # ::from_properties, #object

  # missing 'value' property
  # unexpected property
  example do
    properties = {'object_type' => 'string'}
    expect{ Sumac::Messages::Component::String.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'value' property
  example do
    properties = {'object_type' => 'string', 'value' => 1}
    expect{ Sumac::Messages::Component::String.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # all properties present and valid
  example do
    properties = {'object_type' => 'string', 'value' => 'abc'}
    component = Sumac::Messages::Component::String.from_properties(properties)
    expect(component).to be_a(Sumac::Messages::Component::String)
    value = component.object
    expect(value).to eq('abc')
  end

end
