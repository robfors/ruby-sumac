require 'sumac'

# make sure it exists
describe Sumac::Calls::LocalCalls do

  def build_local_calls
    connection = instance_double('Sumac::Connection')
    id_allocator = instance_double('Sumac::IDAllocator')
    allow(Sumac::IDAllocator).to receive(:new).and_return(id_allocator)
    calls = Sumac::Calls::LocalCalls.new(connection)
  end

  # ::new
  example do
    connection = instance_double('Sumac::Connection')
    id_allocator = instance_double('Sumac::IDAllocator')
    expect(Sumac::IDAllocator).to receive(:new).with(no_args).and_return(id_allocator)
    calls = Sumac::Calls::LocalCalls.new(connection)
    expect(calls.instance_variable_get(:@connection)).to be(connection)
    expect(calls.instance_variable_get(:@calls)).to eq({})
    expect(calls.instance_variable_get(:@id_allocator)).to be(id_allocator)
    expect(calls).to be_a(Sumac::Calls::LocalCalls)
  end

  # #any?

  # no calls
  example do
    calls = build_local_calls
    expect(calls.any?).to be(false)
  end

  # a call
  example do
    calls = build_local_calls
    call = instance_double('Sumac::Calls::LocalCall')
    calls.instance_variable_set(:@calls, {2 => call})
    expect(calls.any?).to be(true)
  end

  # #cancel
  example do
    calls = build_local_calls
    call = instance_double('Sumac::Calls::LocalCall')
    calls.instance_variable_set(:@calls, {2 => call})
    expect(call).to receive(:cancel).with(no_args)
    expect(calls).to receive(:finished).with(call)
    calls.cancel
  end

  # #process_request

  # object not sendable
  example do
    calls = build_local_calls
    object = instance_double(Class.new { include Sumac::Expose })
    method = 'm'
    arguments = [1, :a]
    request = {object: object, method: method, arguments: arguments}
    connection = calls.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:ensure_sendable).with(object).and_raise(Sumac::StaleObjectError)
    expect{ calls.process_request(request) }.to raise_error(Sumac::StaleObjectError)
  end

  # argument not sendable
  example do
    calls = build_local_calls
    object = instance_double(Class.new { include Sumac::Expose })
    method = 'm'
    arguments = [1, :a]
    request = {object: object, method: method, arguments: arguments}
    connection = calls.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:ensure_sendable).with(object)
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:ensure_sendable).with(arguments[0]).and_raise(Sumac::UnexposedObjectError)
    expect{ calls.process_request(request) }.to raise_error(Sumac::UnexposedObjectError)
  end

  # sendable
  example do
    calls = build_local_calls
    object = instance_double(Class.new { include Sumac::Expose })
    method = 'm'
    arguments = [1, :a]
    request = {object: object, method: method, arguments: arguments}
    connection = calls.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:ensure_sendable).with(object)
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:ensure_sendable).with(arguments[0])
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:ensure_sendable).with(arguments[1])
    id_allocator = calls.instance_variable_get(:@id_allocator)
    id = 0
    expect(id_allocator).to receive(:allocate).with(no_args).and_return(id)
    call = instance_double('Sumac::Calls::LocalCall')
    expect(Sumac::Calls::LocalCall).to receive(:new).with(connection, id: id, object: object, method: method, arguments: arguments).and_return(call)
    expect(call).to receive(:send).with(no_args).and_return(nil)
    future = instance_double('QuackConcurrency::Future')
    expect(call).to receive(:return_future).with(no_args).and_return(future)
    expect(calls.process_request(request)).to be(future)
    expect(calls.instance_variable_get(:@calls)).to eq({id => call})
  end

  # #process_response_message

  # no call with that id
  example do
    calls = build_local_calls
    message = instance_double('Sumac::Messages::CallResponse')
    id = 0
    expect(message).to receive(:id).with(no_args).and_return(id)
    expect{ calls.process_response_message(message) }.to raise_error(Sumac::ProtocolError)
  end

  # call exists with that id
  example do
    calls = build_local_calls
    id = 0
    message = instance_double('Sumac::Messages::CallResponse')
    call = instance_double('Sumac::Calls::LocalCall')
    calls.instance_variable_set(:@calls, {id => call})
    expect(message).to receive(:id).with(no_args).and_return(id)
    expect(call).to receive(:process_response_message).with(message)
    expect(calls).to receive(:finished).with(call)
    calls.process_response_message(message)
  end

  # #finished
  example do
    calls = build_local_calls
    call = instance_double('Sumac::Calls::LocalCall')
    id = 0
    calls.instance_variable_set(:@calls, {id => call})
    expect(call).to receive(:id).with(no_args).and_return(id)
    id_allocator = calls.instance_variable_get(:@id_allocator)
    expect(call).to receive(:id).with(no_args).and_return(id)
    expect(id_allocator).to receive(:free).with(id)
    calls.send(:finished, call)
    expect(calls.instance_variable_get(:@calls)).to eq({})
  end

end
