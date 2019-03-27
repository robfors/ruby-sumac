require 'sumac'

# make sure it exists
describe Sumac::Messages::Component::InternalException do

  # should be a subclass of Base
  example do
    expect(Sumac::Messages::Component::InternalException < Sumac::Messages::Base).to be(true)
  end

  # ::from_object, ::type_from_class, ::map, #properties

  # no message
  example do
    object = Sumac::ArgumentError.new
    component = Sumac::Messages::Component::InternalException.from_object(object)
    expect(component).to be_a(Sumac::Messages::Component::InternalException)
    expect(component.properties).to eq({'object_type'=> 'internal_exception', 'type' => 'argument_exception' })
  end

  # with message
  example do
    object = Sumac::ArgumentError.new('abc')
    component = Sumac::Messages::Component::InternalException.from_object(object)
    expect(component).to be_a(Sumac::Messages::Component::InternalException)
    expect(component.properties).to eq({'object_type'=> 'internal_exception', 'type' => 'argument_exception', 'message' => 'abc'})
  end

  # ::from_properties, ::class_from_type, #object

  # missing 'type' property
  # unexpected property
  example do
    properties = {'object_type'=> 'internal_exception', 'message' => 'abc'}
    expect{ Sumac::Messages::Component::InternalException.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'type' property
  example do
    properties = {'object_type'=> 'internal_exception', 'type' => 'none'}
    expect{ Sumac::Messages::Component::InternalException.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # missing 'message' property is ok
  example do
    properties = {'object_type'=> 'internal_exception', 'type' => 'argument_exception'}
    component = Sumac::Messages::Component::InternalException.from_properties(properties)
    expect(component).to be_a(Sumac::Messages::Component::InternalException)
    error = component.object
    expect(error).to be_a(Sumac::ArgumentError)
    expect(error.message).to eq(Sumac::ArgumentError.new.message)
  end

  # all properties present
  example do
    properties = {'object_type'=> 'internal_exception', 'type' => 'argument_exception', 'message' => 'abc'}
    component = Sumac::Messages::Component::InternalException.from_properties(properties)
    expect(component).to be_a(Sumac::Messages::Component::InternalException)
    error = component.object
    expect(error).to be_a(Sumac::ArgumentError)
    expect(error.message).to eq('abc')
  end

  # ::class_from_type, ::map
  example do
    expect(Sumac::Messages::Component::InternalException.class_from_type('argument_exception')).to eq(Sumac::ArgumentError)
    expect(Sumac::Messages::Component::InternalException.class_from_type('unexposed_method_exception')).to eq(Sumac::UnexposedMethodError)
  end

  # ::type_from_class, ::map
  example do
    expect(Sumac::Messages::Component::InternalException.type_from_class(Sumac::ArgumentError)).to eq('argument_exception')
    expect(Sumac::Messages::Component::InternalException.type_from_class(Sumac::UnexposedMethodError)).to eq('unexposed_method_exception')
  end

end
