require 'sumac'

# make sure it exists
describe Sumac::Messages::Component::Null do

  # should be a subclass of Base
  example do
    expect(Sumac::Messages::Component::Null < Sumac::Messages::Base).to be(true)
  end

  # ::from_object, #properties

  example do
    component = Sumac::Messages::Component::Null.from_object
    expect(component).to be_a(Sumac::Messages::Component::Null)
    expect(component.properties).to eq({ 'object_type' => 'null' })
  end

  # ::from_properties, #object

  # unexpected property
  example do
    properties = {'object_type' => 'null', 'value' => nil}
    expect{ Sumac::Messages::Component::Null.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # all properties present and valid
  example do
    properties = {'object_type' => 'null'}
    component = Sumac::Messages::Component::Null.from_properties(properties)
    expect(component).to be_a(Sumac::Messages::Component::Null)
    value = component.object
    expect(value).to be_nil
  end

end
