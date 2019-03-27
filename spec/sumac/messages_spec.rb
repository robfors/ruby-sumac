require 'sumac'

# make sure it exists
describe Sumac::Messages do

  # ::from_json

  # not valid JSON
  example do
    message_string = '{ "a" : 1 '
    expect{ Sumac::Messages.from_json(message_string) }.to raise_error(Sumac::ProtocolError)
  end

  # max json nesting will not raise error
  example do
    root_object = {}
    current_object = root_object
    (Sumac::Messages::Message.max_json_nesting_depth - 1).times do
      new_object = {}
      current_object['a'] = new_object
      current_object = new_object
    end
    current_object['a'] = 1
    message_string = JSON.generate(root_object, max_nesting: false)
    message = instance_double('Sumac::Messages::CallRequest')
    expect(Sumac::Messages).to receive(:from_properties).with(root_object).and_return(message)
    expect(Sumac::Messages.from_json(message_string)).to be(message)
  end

  # surpassing max json nesting will raise error
  example do
    root_object = {}
    current_object = root_object
    Sumac::Messages::Message.max_json_nesting_depth.times do
      new_object = {}
      current_object['a'] = new_object
      current_object = new_object
    end
    current_object['a'] = 1
    message_string = JSON.generate(root_object, max_nesting: false)
    expect{ Sumac::Messages.from_json(message_string) }.to raise_error(Sumac::ProtocolError)
  end

  # valid json
  example do
    message_string = '{ "a" : 1 }'
    message = instance_double('Sumac::Messages::CallRequest')
    expect(Sumac::Messages).to receive(:from_properties).with({ 'a' => 1}).and_return(message)
    expect(Sumac::Messages.from_json(message_string)).to be(message)
  end

  # NaN, Infinity and -Infinity should work (as per RFC 4627)
  example do
    message_string = '{ "a" : NaN, "b" : Infinity, "c" : -Infinity }'
    message = instance_double('Sumac::Messages::CallRequest')
    expect(Sumac::Messages).to receive(:from_properties).with({ 'a' => be_nan, 'b' => Float::INFINITY, 'c' => -Float::INFINITY}).and_return(message)
    expect(Sumac::Messages.from_json(message_string)).to be(message)
  end

  # ::from_properties

  # not a hash
  example do
    expect{ Sumac::Messages::from_properties([]) }.to raise_error(Sumac::ProtocolError)
  end

  example do
    properties = { 'message_type' => 'call_request' }
    message_class = double('Sumac::Messages::CallRequest')
    expect(Sumac::Messages).to receive(:get_class).with('call_request').and_return(message_class)
    message = instance_double('Sumac::Messages::CallRequest')
    expect(message_class).to receive(:from_properties).with(properties).and_return(message)
    expect(Sumac::Messages::from_properties(properties)).to be(message)
  end

  # ::get_class

  example do
    expect(Sumac::Messages::get_class('call_request')).to be(Sumac::Messages::CallRequest)
  end

  example do
    expect(Sumac::Messages::get_class('call_response')).to be(Sumac::Messages::CallResponse)
  end

  example do
    expect(Sumac::Messages::get_class('compatibility')).to be(Sumac::Messages::Compatibility)
  end

  example do
    expect(Sumac::Messages::get_class('forget')).to be(Sumac::Messages::Forget)
  end

  example do
    expect(Sumac::Messages::get_class('initialization')).to be(Sumac::Messages::Initialization)
  end

  example do
    expect(Sumac::Messages::get_class('shutdown')).to be(Sumac::Messages::Shutdown)
  end

  example do
    expect{ Sumac::Messages::get_class('other') }.to raise_error(Sumac::ProtocolError)
  end

end
