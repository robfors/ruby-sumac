require 'sumac'

# make sure it exists
describe Sumac::Calls::RemoteCalls do

  def build_remote_calls
    connection = instance_double('Sumac::Connection')
    calls = Sumac::Calls::RemoteCalls.new(connection)
  end

  # ::new
  example do
    connection = instance_double('Sumac::Connection')
    calls = Sumac::Calls::RemoteCalls.new(connection)
    expect(calls.instance_variable_get(:@connection)).to be(connection)
    expect(calls.instance_variable_get(:@calls)).to eq({})
    expect(calls).to be_a(Sumac::Calls::RemoteCalls)
  end

  # #any?

  # no calls
  example do
    calls = build_remote_calls
    expect(calls.any?).to be(false)
  end

  # a call
  example do
    calls = build_remote_calls
    call = instance_double('Sumac::Calls::RemoteCall')
    id = 0
    calls.instance_variable_set(:@calls, {id => call})
    expect(calls.any?).to be(true)
  end

  # #process_request_message

  # call already exists with that id
  example do
    calls = build_remote_calls
    id = 0
    call = instance_double('Sumac::Calls::RemoteCall')
    calls.instance_variable_set(:@calls, {id => call})
    message = instance_double('Sumac::Messages::CallRequest')
    expect(message).to receive(:id).with(no_args).and_return(id)
    expect{ calls.process_request_message(message) }.to raise_error(Sumac::ProtocolError)
  end

  example do
    calls = build_remote_calls
    id = 0
    message = instance_double('Sumac::Messages::CallRequest')
    expect(message).to receive(:id).with(no_args).and_return(id)
    connection = calls.instance_variable_get(:@connection)
    call = instance_double('Sumac::Calls::RemoteCall')
    expect(Sumac::Calls::RemoteCall).to receive(:new).with(connection).and_return(call)
    expect(call).to receive(:process_request_message).with(message)
    expect(message).to receive(:id).with(no_args).and_return(id)
    calls.process_request_message(message)
    expect(calls.instance_variable_get(:@calls)).to eq({id => call})
  end

  # #process_response

  # quiet: false
  example do
    calls = build_remote_calls
    call = instance_double('Sumac::Calls::RemoteCall')
    expect(call).to receive(:process_response).with(no_args)
    expect(calls).to receive(:finished).with(call)
    calls.process_response(call, quiet: false)
  end

  # quiet: true
  example do
    calls = build_remote_calls
    call = instance_double('Sumac::Calls::RemoteCall')
    expect(calls).to receive(:finished).with(call)
    calls.process_response(call, quiet: true)
  end

  # #validate_request
  example do
    calls = build_remote_calls
    call = instance_double('Sumac::Calls::RemoteCall')
    expect(call).to receive(:validate_request).with(no_args)
    calls.validate_request(call)
  end

  # #finished
  example do
    calls = build_remote_calls
    id = 0
    call = instance_double('Sumac::Calls::RemoteCall')
    calls.instance_variable_set(:@calls, {id => call})
    expect(call).to receive(:id).with(no_args).and_return(id)
    calls.send(:finished, call)
    expect(calls.instance_variable_get(:@calls)).to eq({})
  end

end
