require 'sumac'

# make sure it exists
describe Sumac::Messages::Component::Float do

  # should be a subclass of Base
  example do
    expect(Sumac::Messages::Component::Float < Sumac::Messages::Base).to be(true)
  end

  # ::from_object, #properties

  example do
    object = 1.2
    component = Sumac::Messages::Component::Float.from_object(object)
    expect(component).to be_a(Sumac::Messages::Component::Float)
    expect(component.properties).to eq({'object_type' => 'float', 'value' => 1.2})
  end

  # ::from_properties, #object

  # missing 'value' property
  # unexpected property
  example do
    properties = {'object_type' => 'float'}
    expect{ Sumac::Messages::Component::Float.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'value' property
  example do
    properties = {'object_type' => 'float', 'value' => '1.2'}
    expect{ Sumac::Messages::Component::Float.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # all properties present and valid
  example do
    properties = {'object_type' => 'float', 'value' => 1.2}
    component = Sumac::Messages::Component::Float.from_properties(properties)
    expect(component).to be_a(Sumac::Messages::Component::Float)
    value = component.object
    expect(value).to eq(1.2)
  end

end
