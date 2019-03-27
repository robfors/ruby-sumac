require 'sumac'

# make sure it exists
describe Sumac::Calls::LocalCall do

  def build_local_call
    connection = instance_double('Sumac::Connection')
    id = 0
    object = instance_double(Class.new { include Sumac::Expose })
    method = 'm'
    arguments = [1, :a]
    return_future = instance_double('QuackConcurrency::Future')
    allow(QuackConcurrency::Future).to receive(:new).and_return(return_future)
    call = Sumac::Calls::LocalCall.new(connection, id: id, object: object, method: method, arguments: arguments)
  end

  # ::new
  example do
    connection = instance_double('Sumac::Connection')
    id = 0
    object = Object.new
    method = 'm'
    arguments = [1, :a]
    return_future = instance_double('QuackConcurrency::Future')
    expect(QuackConcurrency::Future).to receive(:new).with(no_args).and_return(return_future)
    call = Sumac::Calls::LocalCall.new(connection, id: id, object: object, method: method, arguments: arguments)
    expect(call.instance_variable_get(:@id)).to be(id)
    expect(call.instance_variable_get(:@object)).to be(object)
    expect(call.instance_variable_get(:@object_reference)).to be_nil
    expect(call.instance_variable_get(:@method)).to be(method)
    expect(call.instance_variable_get(:@arguments)).to be(arguments)
    expect(call.instance_variable_get(:@arguments_references)).to be_nil
    expect(call.instance_variable_get(:@return_future)).to be(return_future)
    expect(call).to be_a(Sumac::Calls::LocalCall)
  end

  # #cancel
  example do
    call = build_local_call
    return_future = call.instance_variable_get(:@return_future)
    expect(return_future).to receive(:raise).with(Sumac::ClosedObjectRequestBrokerError)
    call.cancel
  end

  # #id
  example do
    call = build_local_call
    expect(call.id).to be(call.instance_variable_get(:@id))
  end

  # #process_response_message

  # rejected
  example do
    call = build_local_call
    messege = instance_double('Sumac::Messeges::CallResponse')
    rejected_exception = instance_double('Sumac::ArgumentError')
    expect(messege).to receive(:rejected_exception).with(no_args).and_return(rejected_exception)
    expect(call).to receive(:rejected).with(no_args)
    expect(messege).to receive(:rejected_exception).with(no_args).and_return(rejected_exception)
    return_future = call.instance_variable_get(:@return_future)
    expect(return_future).to receive(:raise).with(rejected_exception)
    call.process_response_message(messege)
  end

  # exception
  example do
    call = build_local_call
    messege = instance_double('Sumac::Messeges::CallResponse')
    expect(messege).to receive(:rejected_exception).with(no_args).and_return(nil)
    expect(call).to receive(:accepted).with(no_args)
    exception = instance_double('StandardError')
    expect(messege).to receive(:exception).with(no_args).and_return(exception)
    expect(messege).to receive(:exception).with(no_args).and_return(exception)
    return_future = call.instance_variable_get(:@return_future)
    expect(return_future).to receive(:raise).with(exception)
    call.process_response_message(messege)
  end

  # no exception
  example do
    call = build_local_call
    messege = instance_double('Sumac::Messeges::CallResponse')
    expect(messege).to receive(:rejected_exception).with(no_args).and_return(nil)
    expect(call).to receive(:accepted).with(no_args)
    expect(messege).to receive(:exception).with(no_args).and_return(nil)
    return_value_properties = instance_double('Sumac::Messages::Component::Exposed')
    return_value = double
    expect(messege).to receive(:return_value).with(no_args).and_return(return_value_properties)
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:convert_properties_to_object).with(return_value_properties).and_return(return_value)
    return_future = call.instance_variable_get(:@return_future)
    expect(return_future).to receive(:set).with(return_value)
    call.process_response_message(messege)
  end

  # #return_future
  example do
    call = build_local_call
    expect(call.return_future).to be(call.instance_variable_get(:@return_future))
  end

  # #send
  example do
    call = build_local_call
    expect(call).to receive(:parse_objects).with(no_args)
    object_reference = instance_double('Sumac::Objects::LocalReference')
    call.instance_variable_set(:@object_reference, object_reference)
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    object_properties = double
    expect(objects).to receive(:convert_reference_to_properties).with(object_reference).and_return(object_properties)
    arguments_references = [1, 2]
    call.instance_variable_set(:@arguments_references, arguments_references)
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    arguments_properties = [1, 2]
    expect(objects).to receive(:convert_reference_to_properties).with(arguments_references[0]).and_return(arguments_properties[0])
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:convert_reference_to_properties).with(arguments_references[1]).and_return(arguments_properties[1])
    id = call.instance_variable_get(:@id)
    method = call.instance_variable_get(:@method)
    message = instance_double('Sumac::Messages::CallRequest')
    expect(Sumac::Messages::CallRequest).to receive(:build).with(id: id, object: object_properties, method: method, arguments: arguments_properties).and_return(message)
    messenger = instance_double('Sumac::Messenger')
    expect(connection).to receive(:messenger).with(no_args).and_return(messenger)
    expect(messenger).to receive(:send).with(message)
    call.send
  end

  # #accepted
  example do
    call = build_local_call
    arguments_references = [1, 2]
    call.instance_variable_set(:@arguments_references, arguments_references)
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:accept_reference).with(arguments_references[0])
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:accept_reference).with(arguments_references[1])
    call.__send__(:accepted)
  end

  # #parse_objects
  example do
    call = build_local_call
    object = call.instance_variable_get(:@object)
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    object_reference = instance_double('Sumac::Objects::LocalReference')
    expect(objects).to receive(:convert_object_to_reference).with(object, build: false).and_return(object_reference)
    arguments = call.instance_variable_get(:@arguments)
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    arguments_references = [1, :a]
    expect(objects).to receive(:convert_object_to_reference).with(arguments[0], tentative: true).and_return(arguments_references[0])
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:convert_object_to_reference).with(arguments[1], tentative: true).and_return(arguments_references[1])
    call.__send__(:parse_objects)
    expect(call.instance_variable_get(:@object_reference)).to be(object_reference)
    expect(call.instance_variable_get(:@arguments_references)).to eq(arguments_references)
  end

  # #rejected
  example do
    call = build_local_call
    arguments_references = [1, 2]
    call.instance_variable_set(:@arguments_references, arguments_references)
    connection = call.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:reject_reference).with(arguments_references[0])
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:reject_reference).with(arguments_references[1])
    call.__send__(:rejected)
  end

end
