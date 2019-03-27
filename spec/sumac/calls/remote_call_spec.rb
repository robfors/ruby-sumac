require 'sumac'

# make sure it exists
describe Sumac::Calls::RemoteCall do

  def build_call
    connection = instance_double('Sumac::Connection')
    call = Sumac::Calls::RemoteCall.new(connection)
  end

  # ::new
  example do
    connection = instance_double('Sumac::Connection')
    call = Sumac::Calls::RemoteCall.new(connection)
    expect(call.instance_variable_get(:@connection)).to be(connection)
    expect(call.instance_variable_get(:@id)).to be_nil
    expect(call.instance_variable_get(:@object)).to be_nil
    expect(call.instance_variable_get(:@object_reference)).to be_nil
    expect(call.instance_variable_get(:@method)).to be_nil
    expect(call.instance_variable_get(:@arguments_references)).to be_nil
    expect(call.instance_variable_get(:@arguments)).to be_nil
    expect(call.instance_variable_get(:@return_error)).to be_nil
    expect(call.instance_variable_get(:@return_value)).to be_nil
    expect(call).to be_a(Sumac::Calls::RemoteCall)
  end

  # #id
  example do
    call = build_call
    id = 0
    call.instance_variable_set(:@id, id)
    expect(call.id).to be(id)
  end

  # #process_request_message

  # message invalid
  example do
    call = build_call
    message = instance_double('Sumac::Messages::CallRequest')
    expect(call).to receive(:parse_message).with(message).and_raise(Sumac::ProtocolError)
    expect{ call.process_request_message(message) }.to raise_error(Sumac::ProtocolError)
  end

  # request invalid
  example do
    call = build_call
    message = instance_double('Sumac::Messages::CallRequest')
    expect(call).to receive(:parse_message).with(message)
    expect(Thread).to receive(:new).with(no_args).and_yield
    expect(call).to receive(:build_objects).with(no_args)
    connection = call.instance_variable_get(:@connection)
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    expect(object_request_broker).to receive(:validate_request).with(call).and_return(false)
    call.process_request_message(message)
  end

  # request valid
  example do
    call = build_call
    message = instance_double('Sumac::Messages::CallRequest')
    expect(call).to receive(:parse_message).with(message)
    expect(Thread).to receive(:new).with(no_args).and_yield
    expect(call).to receive(:build_objects).with(no_args)
    connection = call.instance_variable_get(:@connection)
    object_request_broker = instance_double('Sumac::ObjectRequestBroker')
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    expect(object_request_broker).to receive(:validate_request).with(call).and_return(true)
    expect(call).to receive(:process_call).with(no_args)
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    expect(object_request_broker).to receive(:respond).with(call)
    call.process_request_message(message)
  end

  # #process_response

  # return value, not sendable
  example do
    call = build_call
    call.instance_variable_set(:@return_error, nil)
    value = double
    call.instance_variable_set(:@return_value, value)
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:ensure_sendable).with(value).and_raise(Sumac::UnexposedObjectError)
    expect(call).to receive(:respond_with_error).with(instance_of(Sumac::UnexposedObjectError))
    call.process_response
  end

  # return value, sendable
  example do
    call = build_call
    call.instance_variable_set(:@return_error, nil)
    value = double
    call.instance_variable_set(:@return_value, value)
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:ensure_sendable).with(value)
    expect(call).to receive(:respond_with_value).with(value)
    call.process_response
  end

  # return error
  example do
    call = build_call
    error = instance_double('StandardError')
    call.instance_variable_set(:@return_error, error)
    expect(call).to receive(:respond_with_error).with(error)
    call.process_response
  end

  # #validate_request

  # method invalid
  example do
    call = build_call
    message = instance_double('Sumac::Messages::CallRequest')
    rejected_error = Sumac::UnexposedMethodError.new
    expect(call).to receive(:validate_method).with(no_args).and_return(rejected_error)
    expect(call).to receive(:reject).with(no_args)
    expect(call).to receive(:respond_with_rejected_error).with(rejected_error)
    expect(call.validate_request).to be(false)
  end

  # arguments invalid
  example do
    call = build_call
    message = instance_double('Sumac::Messages::CallRequest')
    expect(call).to receive(:validate_method).with(no_args).and_return(nil)
    rejected_error = Sumac::ArgumentError.new
    expect(call).to receive(:validate_arguments).with(no_args).and_return(rejected_error)
    expect(call).to receive(:reject).with(no_args)
    expect(call).to receive(:respond_with_rejected_error).with(rejected_error)
    expect(call.validate_request).to be(false)
  end

  # valid
  example do
    call = build_call
    message = instance_double('Sumac::Messages::CallRequest')
    expect(call).to receive(:validate_method).with(no_args).and_return(nil)
    expect(call).to receive(:validate_arguments).with(no_args).and_return(nil)
    expect(call).to receive(:accept).with(no_args)
    expect(call.validate_request).to be(true)
  end

  # #accept
  example do
    call = build_call
    arguments_references = [double, double]
    call.instance_variable_set(:@arguments_references, arguments_references)
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:accept_reference).with(arguments_references[0])
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:accept_reference).with(arguments_references[1])
    call.send(:accept)
  end

  # #acceptable_argument_count

  # m()
  example do
    call = build_call
    object = Object.new
    object.define_singleton_method(:m) {}
    call.instance_variable_set(:@object, object)
    method = 'm'
    call.instance_variable_set(:@method, method)
    expect(call.send(:acceptable_argument_count)).to eq(0..0)
  end

  # m(a)
  example do
    call = build_call
    object = Object.new
    object.define_singleton_method(:m) { |a| }
    call.instance_variable_set(:@object, object)
    method = 'm'
    call.instance_variable_set(:@method, method)
    expect(call.send(:acceptable_argument_count)).to eq(1..1)
  end

  # m(a = nil)
  example do
    call = build_call
    object = Object.new
    object.define_singleton_method(:m) { |a = nil| }
    call.instance_variable_set(:@object, object)
    method = 'm'
    call.instance_variable_set(:@method, method)
    expect(call.send(:acceptable_argument_count)).to eq(0..1)
  end

  # m(*a)
  example do
    call = build_call
    object = Object.new
    object.define_singleton_method(:m) { |*a| }
    call.instance_variable_set(:@object, object)
    method = 'm'
    call.instance_variable_set(:@method, method)
    expect(call.send(:acceptable_argument_count)).to eq(0..Float::INFINITY)
  end

  # m(a, b = nil)
  example do
    call = build_call
    object = Object.new
    object.define_singleton_method(:m) { |a, b = nil| }
    call.instance_variable_set(:@object, object)
    method = 'm'
    call.instance_variable_set(:@method, method)
    expect(call.send(:acceptable_argument_count)).to eq(1..2)
  end

  # m(a, *b)
  example do
    call = build_call
    object = Object.new
    object.define_singleton_method(:m) { |a, *b| }
    call.instance_variable_set(:@object, object)
    method = 'm'
    call.instance_variable_set(:@method, method)
    expect(call.send(:acceptable_argument_count)).to eq(1..Float::INFINITY)
  end

  # m(a, b = nil, *c)
  example do
    call = build_call
    object = Object.new
    object.define_singleton_method(:m) { |a, b = nil, *c| }
    call.instance_variable_set(:@object, object)
    method = 'm'
    call.instance_variable_set(:@method, method)
    expect(call.send(:acceptable_argument_count)).to eq(1..Float::INFINITY)
  end

  # #build_objects
  example do
    call = build_call
    object_reference = instance_double('Sumac::Objects::LocalReference')
    call.instance_variable_set(:@object_reference, object_reference)
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    object = instance_double(Class.new { include Sumac::Expose })
    expect(objects).to receive(:convert_reference_to_object).with(object_reference).and_return(object)
    arguments_references = [1, 2]
    call.instance_variable_set(:@arguments_references, arguments_references)
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    arguments = [1, 2]
    expect(objects).to receive(:convert_reference_to_object).with(arguments_references[0]).and_return(arguments[0])
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:convert_reference_to_object).with(arguments_references[1]).and_return(arguments[1])
    call.send(:build_objects)
    expect(call.instance_variable_get(:@object)).to be(object)
    expect(call.instance_variable_get(:@arguments)).to eq(arguments)
  end

  # #parse_message

  # message invalid
  example do
    call = build_call
    message = instance_double('Sumac::Messages::CallRequest')
    id = 0
    expect(message).to receive(:id).with(no_args).and_return(id)
    object_properties = instance_double('Sumac::Messages::Component::Exposed')
    expect(message).to receive(:object).with(no_args).and_return(object_properties)
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:convert_properties_to_reference).with(object_properties, build: false).and_raise(Sumac::ProtocolError)
    expect{ call.send(:parse_message, message) }.to raise_error(Sumac::ProtocolError)
  end

  # message valid
  example do
    call = build_call
    message = instance_double('Sumac::Messages::CallRequest')
    id = 0
    expect(message).to receive(:id).with(no_args).and_return(id)
    object_properties = instance_double('Sumac::Messages::Component::Exposed')
    expect(message).to receive(:object).with(no_args).and_return(object_properties)
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    object_reference = instance_double('Sumac::Objects::LocalReference')
    expect(objects).to receive(:convert_properties_to_reference).with(object_properties, build: false).and_return(object_reference)
    method = 'm'
    expect(message).to receive(:method).with(no_args).and_return(method)
    arguments_properties = [instance_double('Sumac::Messages::Component::Integer'), instance_double('Sumac::Messages::Component::Integer')]
    expect(message).to receive(:arguments).with(no_args).and_return(arguments_properties)
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    arguments_references = [1, 2]
    expect(objects).to receive(:convert_properties_to_reference).with(arguments_properties[0], tentative: true).and_return(arguments_references[0])
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:convert_properties_to_reference).with(arguments_properties[1], tentative: true).and_return(arguments_references[1])
    call.send(:parse_message, message)
    expect(call.instance_variable_get(:@id)).to be(id)
    expect(call.instance_variable_get(:@object_reference)).to be(object_reference)
    expect(call.instance_variable_get(:@method)).to be(method)
    expect(call.instance_variable_get(:@arguments_references)).to eq(arguments_references)
  end

  # #process_call

  # error
  example do
    call = build_call
    object = instance_double(Class.new { include Sumac::Expose; expose_method :m; def m(*a); end })
    call.instance_variable_set(:@object, object)
    method = 'm'
    call.instance_variable_set(:@method, method)
    arguments = [1, :a]
    call.instance_variable_set(:@arguments, arguments)
    error = StandardError.new
    expect(object).to receive(:m).with(*arguments).and_raise(error)
    call.send(:process_call)
    expect(call.instance_variable_get(:@return_error)).to be(error)
  end

  # value
  example do
    call = build_call
    object = instance_double(Class.new { include Sumac::Expose; expose_method :m; def m(*a); end })
    call.instance_variable_set(:@object, object)
    method = 'm'
    call.instance_variable_set(:@method, method)
    arguments = [1, :a]
    call.instance_variable_set(:@arguments, arguments)
    value = double
    expect(object).to receive(:m).with(*arguments).and_return(value)
    call.send(:process_call)
    expect(call.instance_variable_get(:@return_error)).to be_nil
    expect(call.instance_variable_get(:@return_value)).to be(value)
  end

  # #reject
  example do
    call = build_call
    arguments_references = [double, double]
    call.instance_variable_set(:@arguments_references, arguments_references)
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:reject_reference).with(arguments_references[0])
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:reject_reference).with(arguments_references[1])
    call.send(:reject)
  end

  # #respond_with_error
  example do
    call = build_call
    id = 0
    call.instance_variable_set(:@id, id)
    error = instance_double('StandardError')
    connection = call.instance_variable_get(:@connection)
    message = instance_double('Sumac::Messages::CallResponse')
    expect(Sumac::Messages::CallResponse).to receive(:build).with(id: id, exception: error).and_return(message)
    messenger = instance_double('Sumac::Messenger')
    expect(connection).to receive(:messenger).with(no_args).and_return(messenger)
    expect(messenger).to receive(:send).with(message)
    call.send(:respond_with_error, error)
  end

  # #respond_with_rejected_error
  example do
    call = build_call
    id = 0
    call.instance_variable_set(:@id, id)
    error = instance_double('Sumac::ArgumentError')
    connection = call.instance_variable_get(:@connection)
    message = instance_double('Sumac::Messages::CallResponse')
    expect(Sumac::Messages::CallResponse).to receive(:build).with(id: id, rejected_exception: error).and_return(message)
    messenger = instance_double('Sumac::Messenger')
    expect(connection).to receive(:messenger).with(no_args).and_return(messenger)
    expect(messenger).to receive(:send).with(message)
    call.send(:respond_with_rejected_error, error)
  end

  # #respond_with_value
  example do
    call = build_call
    id = 0
    call.instance_variable_set(:@id, id)
    value = 1
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    return_value_properties = instance_double('Sumac::Messages::Component::Integer')
    expect(objects).to receive(:convert_object_to_properties).with(value).and_return(return_value_properties)
    message = instance_double('Sumac::Messages::CallResponse')
    expect(Sumac::Messages::CallResponse).to receive(:build).with(id: id, return_value: return_value_properties).and_return(message)
    messenger = instance_double('Sumac::Messenger')
    expect(connection).to receive(:messenger).with(no_args).and_return(messenger)
    expect(messenger).to receive(:send).with(message)
    call.send(:respond_with_value, value)
  end

  # #validate_arguments
  
  # within range, min == max
  example do
    call = build_call
    arguments = []
    call.instance_variable_set(:@arguments, arguments)
    expect(call).to receive(:acceptable_argument_count).and_return(0..0)
    expect(call.send(:validate_arguments)).to be_nil
  end

  # within range, start boundry
  example do
    call = build_call
    arguments = [0,1]
    call.instance_variable_set(:@arguments, arguments)
    expect(call).to receive(:acceptable_argument_count).and_return(2..3)
    expect(call.send(:validate_arguments)).to be_nil
  end

  # within range, middle
  example do
    call = build_call
    arguments = [0,1,3]
    call.instance_variable_set(:@arguments, arguments)
    expect(call).to receive(:acceptable_argument_count).and_return(2..3)
    expect(call.send(:validate_arguments)).to be_nil
  end

  # within range, end boundry
  example do
    call = build_call
    arguments = [0,1,3]
    call.instance_variable_set(:@arguments, arguments)
    expect(call).to receive(:acceptable_argument_count).and_return(2..3)
    expect(call.send(:validate_arguments)).to be_nil
  end

  # out of range, min == max
  example do
    call = build_call
    arguments = [0,1]
    call.instance_variable_set(:@arguments, arguments)
    expect(call).to receive(:acceptable_argument_count).and_return(1..1)
    error = call.send(:validate_arguments)
    expect(error).to be_a(Sumac::ArgumentError)
    expect(error.message).to eq('wrong number of arguments (given 2, expected 1)')
  end

  # out of range, splat
  example do
    call = build_call
    arguments = []
    call.instance_variable_set(:@arguments, arguments)
    expect(call).to receive(:acceptable_argument_count).and_return(1..Float::INFINITY)
    error = call.send(:validate_arguments)
    expect(error).to be_a(Sumac::ArgumentError)
    expect(error.message).to eq('wrong number of arguments (given 0, expected 1+)')
  end

  # out of range, start boundry
  example do
    call = build_call
    arguments = []
    call.instance_variable_set(:@arguments, arguments)
    expect(call).to receive(:acceptable_argument_count).and_return(1..3)
    error = call.send(:validate_arguments)
    expect(error).to be_a(Sumac::ArgumentError)
    expect(error.message).to eq('wrong number of arguments (given 0, expected 1..3)')
  end

  # out of range, end boundry
  example do
    call = build_call
    arguments = [0,1,2,3]
    call.instance_variable_set(:@arguments, arguments)
    expect(call).to receive(:acceptable_argument_count).and_return(1..3)
    error = call.send(:validate_arguments)
    expect(error).to be_a(Sumac::ArgumentError)
    expect(error.message).to eq('wrong number of arguments (given 4, expected 1..3)')
  end

  # #validate_method

  # invalid
  example do
    call = build_call
    object = instance_double(Class.new { include Sumac::Expose })
    call.instance_variable_set(:@object, object)
    method = 'm'
    call.instance_variable_set(:@method, method)
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:exposed_method?).with(object, method).and_return(false)
    expect(call.send(:validate_method)).to be_an_instance_of(Sumac::UnexposedMethodError)
  end

  # valid
  example do
    call = build_call
    object = instance_double(Class.new { include Sumac::Expose; expose_method :m; def m(*a); end })
    call.instance_variable_set(:@object, object)
    method = 'm'
    call.instance_variable_set(:@method, method)
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:exposed_method?).with(object, method).and_return(true)
    expect(call.send(:validate_method)).to be_nil
  end

end