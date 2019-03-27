require 'sumac'

# make sure it exists
describe Sumac::Messages::Component::Boolean do

  # should be a subclass of Base
  example do
    expect(Sumac::Messages::Component::Boolean < Sumac::Messages::Base).to be(true)
  end

  # ::from_object, #properties

  example do
    object = true
    component = Sumac::Messages::Component::Boolean.from_object(object)
    expect(component).to be_a(Sumac::Messages::Component::Boolean)
    expect(component.properties).to eq({ 'object_type' => 'boolean', 'value' => true})
  end

  # ::from_properties, #object

  # missing 'value' property
  # unexpected property
  example do
    properties = {'object_type' => 'boolean'}
    expect{ Sumac::Messages::Component::Boolean.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'value' property
  example do
    properties = {'object_type' => 'boolean', 'value' => 'true'}
    expect{ Sumac::Messages::Component::Boolean.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # all properties present and valid
  example do
    properties = {'object_type' => 'boolean', 'value' => true}
    component = Sumac::Messages::Component::Boolean.from_properties(properties)
    expect(component).to be_a(Sumac::Messages::Component::Boolean)
    value = component.object
    expect(value).to eq(true)
  end

end
