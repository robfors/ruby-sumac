require 'sumac'

# make sure it exists
describe Sumac::Calls do

  def build_calls
    connection = instance_double('Sumac::Connection')
    local_calls = instance_double('Sumac::Calls::LocalCalls')
    allow(Sumac::Calls::LocalCalls).to receive(:new).and_return(local_calls)
    remote_calls = instance_double('Sumac::Calls::RemoteCalls')
    allow(Sumac::Calls::RemoteCalls).to receive(:new).and_return(remote_calls)
    calls = Sumac::Calls.new(connection)
  end

  # ::new
  example do
    connection = instance_double('Sumac::Connection')
    local_calls = instance_double('Sumac::Calls::LocalCalls')
    expect(Sumac::Calls::LocalCalls).to receive(:new).with(connection).and_return(local_calls)
    remote_calls = instance_double('Sumac::Calls::RemoteCalls')
    expect(Sumac::Calls::RemoteCalls).to receive(:new).with(connection).and_return(remote_calls)
    calls = Sumac::Calls.new(connection)
    expect(calls.instance_variable_get(:@connection)).to be(connection)
    expect(calls.instance_variable_get(:@local)).to be(local_calls)
    expect(calls.instance_variable_get(:@remote)).to be(remote_calls)
    expect(calls).to be_a(Sumac::Calls)
  end

  # #any?

  # no calls
  example do
    calls = build_calls
    local_calls = calls.instance_variable_get(:@local)
    expect(local_calls).to receive(:any?).with(no_args).and_return(false)
    remote_calls = calls.instance_variable_get(:@remote)
    expect(remote_calls).to receive(:any?).with(no_args).and_return(false)
    expect(calls.any?).to be(false)
  end

  # local call
  example do
    calls = build_calls
    local_calls = calls.instance_variable_get(:@local)
    expect(local_calls).to receive(:any?).with(no_args).and_return(true)
    expect(calls.any?).to be(true)
  end

  # remote calls
  example do
    calls = build_calls
    local_calls = calls.instance_variable_get(:@local)
    expect(local_calls).to receive(:any?).with(no_args).and_return(false)
    remote_calls = calls.instance_variable_get(:@remote)
    expect(remote_calls).to receive(:any?).with(no_args).and_return(true)
    expect(calls.any?).to be(true)
  end

  # #cancel_local
  example do
    calls = build_calls
    local_calls = calls.instance_variable_get(:@local)
    expect(local_calls).to receive(:cancel).with(no_args)
    calls.cancel_local
  end

  # #process_request
  example do
    calls = build_calls
    request = double
    local_calls = calls.instance_variable_get(:@local)
    expect(local_calls).to receive(:process_request).with(request)
    calls.process_request(request)
  end
  
  # #process_request_message
  example do
    calls = build_calls
    message = double
    remote_calls = calls.instance_variable_get(:@remote)
    expect(remote_calls).to receive(:process_request_message).with(message)
    calls.process_request_message(message)
  end

  # #process_response

  # not quiet
  example do
    calls = build_calls
    response = double
    remote_calls = calls.instance_variable_get(:@remote)
    expect(remote_calls).to receive(:process_response).with(response, quiet: false)
    calls.process_response(response, quiet: false)
  end
  
  # quiet
  example do
    calls = build_calls
    response = double
    remote_calls = calls.instance_variable_get(:@remote)
    expect(remote_calls).to receive(:process_response).with(response, quiet: true)
    calls.process_response(response, quiet: true)
  end

  # #process_response_message
  example do
    calls = build_calls
    message = double
    local_calls = calls.instance_variable_get(:@local)
    expect(local_calls).to receive(:process_response_message).with(message)
    calls.process_response_message(message)
  end

  # #validate_request
  example do
    calls = build_calls
    call = double
    remote_calls = calls.instance_variable_get(:@remote)
    expect(remote_calls).to receive(:validate_request).with(call).and_return(false)
    expect(calls.validate_request(call)).to eq(false)
  end

end
