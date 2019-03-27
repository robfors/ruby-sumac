require 'sumac'

# make sure it exists
describe Sumac::Messages::Component::Exception do

  # should be a subclass of Base
  example do
    expect(Sumac::Messages::Component::Exception < Sumac::Messages::Base).to be(true)
  end

  # ::from_object, #properties

  # no message
  example do
    object = TypeError.new
    component = Sumac::Messages::Component::Exception.from_object(object)
    expect(component).to be_a(Sumac::Messages::Component::Exception)
    expect(component.properties).to eq({'object_type' => 'exception', 'class' => 'TypeError'})
  end

  # with a message
  example do
    object = TypeError.new('abc')
    component = Sumac::Messages::Component::Exception.from_object(object)
    expect(component).to be_a(Sumac::Messages::Component::Exception)
    expect(component.properties).to eq({'object_type' => 'exception', 'class' => 'TypeError', 'message' => 'abc'})
  end

  # ::from_properties, #object

  # missing 'class' property
  # unexpected property
  example do
    properties = {'object_type' => 'exception', 'message' => 'abc'}
    expect{ Sumac::Messages::Component::Exception.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # missing 'message' property is ok
  example do
    properties = {'object_type' => 'exception', 'class' => 'TypeError'}
    component = Sumac::Messages::Component::Exception.from_properties(properties)
    expect(component).to be_a(Sumac::Messages::Component::Exception)
    error = component.object
    expect(error).to be_a(Sumac::RemoteError)
    expect(error.remote_type).to eq('TypeError')
    expect(error.remote_message).to be_nil
  end

  # all properties present
  example do
    properties = {'object_type' => 'exception', 'class' => 'TypeError', 'message' => 'abc'}
    component = Sumac::Messages::Component::Exception.from_properties(properties)
    expect(component).to be_a(Sumac::Messages::Component::Exception)
    error = component.object
    expect(error).to be_a(Sumac::RemoteError)
    expect(error.remote_type).to eq('TypeError')
    expect(error.remote_message).to eq('abc')
  end

end
