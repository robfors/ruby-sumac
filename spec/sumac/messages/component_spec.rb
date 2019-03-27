require 'sumac'

# make sure it exists
describe Sumac::Messages::Component do

  # ::from_object

  # array
  example do
    object = []
    component = instance_double('Sumac::Messages::Component::Array')
    expect(Sumac::Messages::Component::Array).to receive(:from_object).with(object).and_return(component)
    expect(Sumac::Messages::Component.from_object(object)).to be(component)
  end

  # boolean (true)
  example do
    object = true
    component = instance_double('Sumac::Messages::Component::Boolean')
    expect(Sumac::Messages::Component::Boolean).to receive(:from_object).with(object).and_return(component)
    expect(Sumac::Messages::Component.from_object(object)).to be(component)
  end

  # boolean (false)
  example do
    object = false
    component = instance_double('Sumac::Messages::Component::Boolean')
    expect(Sumac::Messages::Component::Boolean).to receive(:from_object).with(object).and_return(component)
    expect(Sumac::Messages::Component.from_object(object)).to be(component)
  end

  # exception
  example do
    object = TypeError.new
    component = instance_double('Sumac::Messages::Component::Exception')
    expect(Sumac::Messages::Component::Exception).to receive(:from_object).with(object).and_return(component)
    expect(Sumac::Messages::Component.from_object(object)).to be(component)
  end

  # exposed
  example do
    object = instance_double('Sumac::Objects::LocalReference')
    allow(object).to receive(:is_a?).and_return(false)
    expect(object).to receive(:respond_to?).with(:origin).and_return(true)
    expect(object).to receive(:respond_to?).with(:id).and_return(true)
    component = instance_double('Sumac::Messages::Component::Exposed')
    expect(Sumac::Messages::Component::Exposed).to receive(:from_object).with(object).and_return(component)
    expect(Sumac::Messages::Component.from_object(object)).to be(component)
  end

  # float
  example do
    object = 1.2
    component = instance_double('Sumac::Messages::Component::Float')
    expect(Sumac::Messages::Component::Float).to receive(:from_object).with(object).and_return(component)
    expect(Sumac::Messages::Component.from_object(object)).to be(component)
  end

  # integer
  example do
    object = 1
    component = instance_double('Sumac::Messages::Component::Integer')
    expect(Sumac::Messages::Component::Integer).to receive(:from_object).with(object).and_return(component)
    expect(Sumac::Messages::Component.from_object(object)).to be(component)
  end

  # map
  example do
    object = {}
    component = instance_double('Sumac::Messages::Component::Map')
    expect(Sumac::Messages::Component::Map).to receive(:from_object).with(object).and_return(component)
    expect(Sumac::Messages::Component.from_object(object)).to be(component)
  end

  # null
  example do
    object = nil
    component = instance_double('Sumac::Messages::Component::Null')
    expect(Sumac::Messages::Component::Null).to receive(:from_object).with(no_args).and_return(component)
    expect(Sumac::Messages::Component.from_object(object)).to be(component)
  end

  # string
  example do
    object = 'abc'
    component = instance_double('Sumac::Messages::Component::String')
    expect(Sumac::Messages::Component::String).to receive(:from_object).with(object).and_return(component)
    expect(Sumac::Messages::Component.from_object(object)).to be(component)
  end

  # ::from_properties

  # not a hash
  example do
    properties = '{}'
    expect{ Sumac::Messages::Component.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # array
  
  # no depth will assume a depth of 1
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'array' }
    component = instance_double('Sumac::Messages::Component::Array')
    expect(Sumac::Messages::Component::Array).to receive(:from_properties).with(properties, 1).and_return(component)
    expect(Sumac::Messages::Component.from_properties(properties)).to be(component)
  end

  # max object nesting will not raise error
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'array' }
    component = instance_double('Sumac::Messages::Component::Array')
    expect(Sumac::Messages::Component::Array).to receive(:from_properties).with(properties, 1).and_return(component)
    expect(Sumac::Messages::Component.from_properties(properties, 1)).to be(component)
  end

  # surpassing max object nesting will raise error
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'array' }
    component = instance_double('Sumac::Messages::Component::Array')
    expect{ Sumac::Messages::Component.from_properties(properties, 2) }.to raise_error(Sumac::ProtocolError)
  end

  # boolean
  # depth should have no effect, try max depth
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'boolean' }
    component = instance_double('Sumac::Messages::Component::Boolean')
    expect(Sumac::Messages::Component::Boolean).to receive(:from_properties).with(properties).and_return(component)
    expect(Sumac::Messages::Component.from_properties(properties, 2)).to be(component)
  end

  # exception
  # depth should have no effect, try max depth
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'exception' }
    component = instance_double('Sumac::Messages::Component::Exception')
    expect(Sumac::Messages::Component::Exception).to receive(:from_properties).with(properties).and_return(component)
    expect(Sumac::Messages::Component.from_properties(properties, 2)).to be(component)
  end

  # exposed
  # depth should have no effect, try max depth
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'exposed' }
    component = instance_double('Sumac::Messages::Component::Exposed')
    expect(Sumac::Messages::Component::Exposed).to receive(:from_properties).with(properties).and_return(component)
    expect(Sumac::Messages::Component.from_properties(properties, 2)).to be(component)
  end

  # float
  # depth should have no effect, try max depth
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'float' }
    component = instance_double('Sumac::Messages::Component::Float')
    expect(Sumac::Messages::Component::Float).to receive(:from_properties).with(properties).and_return(component)
    expect(Sumac::Messages::Component.from_properties(properties, 2)).to be(component)
  end

  # integer
  # depth should have no effect, try max depth
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'integer' }
    component = instance_double('Sumac::Messages::Component::Integer')
    expect(Sumac::Messages::Component::Integer).to receive(:from_properties).with(properties).and_return(component)
    expect(Sumac::Messages::Component.from_properties(properties, 2)).to be(component)
  end

  # internal_exception
  # depth should have no effect, try max depth
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'internal_exception' }
    component = instance_double('Sumac::Messages::Component::InternalException')
    expect(Sumac::Messages::Component::InternalException).to receive(:from_properties).with(properties).and_return(component)
    expect(Sumac::Messages::Component.from_properties(properties, 2)).to be(component)
  end

  # map

  # no depth will assume a depth of 1
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'map' }
    component = instance_double('Sumac::Messages::Component::Map')
    expect(Sumac::Messages::Component::Map).to receive(:from_properties).with(properties, 1).and_return(component)
    expect(Sumac::Messages::Component.from_properties(properties)).to be(component)
  end

  # max object nesting will not raise error
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'map' }
    component = instance_double('Sumac::Messages::Component::Map')
    expect(Sumac::Messages::Component::Map).to receive(:from_properties).with(properties, 1).and_return(component)
    expect(Sumac::Messages::Component.from_properties(properties, 1)).to be(component)
  end

  # surpassing max object nesting will raise error
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'map' }
    component = instance_double('Sumac::Messages::Component::Map')
    expect{ Sumac::Messages::Component.from_properties(properties, 2) }.to raise_error(Sumac::ProtocolError)
  end

  # null
  # depth should have no effect, try max depth
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'null' }
    component = instance_double('Sumac::Messages::Component::Null')
    expect(Sumac::Messages::Component::Null).to receive(:from_properties).with(properties).and_return(component)
    expect(Sumac::Messages::Component.from_properties(properties, 2)).to be(component)
  end

  # string
  # depth should have no effect, try max depth
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'string' }
    component = instance_double('Sumac::Messages::Component::String')
    expect(Sumac::Messages::Component::String).to receive(:from_properties).with(properties).and_return(component)
    expect(Sumac::Messages::Component.from_properties(properties, 2)).to be(component)
  end

  # invalid type
  # depth should have no effect, try max depth
  example do
    stub_const('Sumac::MAX_OBJECT_NESTING_DEPTH', 2)
    properties = { 'object_type' => 'none' }
    expect{ Sumac::Messages::Component.from_properties(properties, 2) }.to raise_error(Sumac::ProtocolError)
  end

end
