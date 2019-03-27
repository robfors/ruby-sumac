require 'sumac'

# make sure it exists
describe Sumac::Messages::CallResponse do

  # should be a subclass of Message
  example do
    expect(Sumac::Messages::CallResponse < Sumac::Messages::Message).to be(true)
  end

  # ::build, #properties, #to_json

  # exception
  example do
    message = Sumac::Messages::CallResponse.build(id: 1, exception: TypeError.new)
    expect(message).to be_a(Sumac::Messages::CallResponse)
    expect(JSON.parse(message.to_json)).to eq({ 'message_type' => 'call_response', 'id' => 1, 'exception' => { 'object_type' => 'exception', 'class' => 'TypeError' } })
  end

  # rejected_exception
  example do
    message = Sumac::Messages::CallResponse.build(id: 1, rejected_exception: Sumac::ArgumentError.new)
    expect(message).to be_a(Sumac::Messages::CallResponse)
    expect(JSON.parse(message.to_json)).to eq({ 'message_type' => 'call_response', 'id' => 1, 'rejected_exception' => { 'object_type' => 'internal_exception', 'type' => 'argument_exception' } })
  end

  # return_value
  example do
    message = Sumac::Messages::CallResponse.build(id: 1, return_value: 1)
    expect(message).to be_a(Sumac::Messages::CallResponse)
    expect(JSON.parse(message.to_json)).to eq({ 'message_type' => 'call_response', 'id' => 1, 'return_value' => { 'object_type' => 'integer', 'value' => 1 } })
  end

  # ::from_properties, #exception, #id, #return_value, #

  # missing or unexpected property
  example do
    properties = { 'message_type' => 'call_response' }
    expect{ Sumac::Messages::CallResponse.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'id' property
  example do
    properties = { 'message_type' => 'call_response', 'id' => '1', 'return_value' => { 'object_type' => 'null' } }
    expect{ Sumac::Messages::CallResponse.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'exception' property
  example do
    properties = { 'message_type' => 'call_response', 'id' => '1', 'exception' => { 'object_type' => 'null' } }
    expect{ Sumac::Messages::CallResponse.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # all properties present and valid for an exception
  example do
    properties = { 'message_type' => 'call_response', 'id' => 1, 'exception' => { 'object_type' => 'exception', 'class' => 'TypeError' } }
    message = Sumac::Messages::CallResponse.from_properties(properties)
    expect(message).to be_a(Sumac::Messages::CallResponse)
    expect(message.exception).to be_a(Sumac::RemoteError)
    expect(message.exception.remote_type).to eq('TypeError')
    expect(message.rejected_exception).to be_nil
  end

  # all properties present and valid for a rejected exception
  example do
    properties = { 'message_type' => 'call_response', 'id' => 1, 'rejected_exception' => { 'object_type' => 'internal_exception', 'type' => 'argument_exception' } }
    message = Sumac::Messages::CallResponse.from_properties(properties)
    expect(message).to be_a(Sumac::Messages::CallResponse)
    expect(message.exception).to be_nil
    expect(message.rejected_exception).to be_a(Sumac::ArgumentError)
  end

    # all properties present and valid for a return value
  example do
    properties = { 'message_type' => 'call_response', 'id' => 1, 'return_value' => { 'object_type' => 'integer', 'value' => 1 } }
    message = Sumac::Messages::CallResponse.from_properties(properties)
    expect(message).to be_a(Sumac::Messages::CallResponse)
    expect(message.exception).to be_nil
    expect(message.rejected_exception).to be_nil
    expect(message.return_value).to eq(1)
  end

end
