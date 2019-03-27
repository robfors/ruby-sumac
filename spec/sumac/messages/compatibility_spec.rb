require 'sumac'

# make sure it exists
describe Sumac::Messages::Compatibility do

  # should be a subclass of Message
  example do
    expect(Sumac::Messages::Compatibility < Sumac::Messages::Message).to be(true)
  end

  # ::build, #properties, #to_json

  example do
    message = Sumac::Messages::Compatibility.build(protocol_version: '1')
    expect(message).to be_a(Sumac::Messages::Compatibility)
    expect(JSON.parse(message.to_json)).to eq({ 'message_type' => 'compatibility', 'protocol_version' => '1' })
  end

  # ::from_properties

  # missing or unexpected property
  example do
    properties = { 'message_type' => 'compatibility' }
    expect{ Sumac::Messages::Compatibility.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # invalid 'protocol_version' property
  example do
    properties = { 'message_type' => 'compatibility', 'protocol_version' => 1 }
    expect{ Sumac::Messages::Compatibility.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # all properties present and valid
  example do
    properties = { 'message_type' => 'compatibility', 'protocol_version' => '1' }
    message = Sumac::Messages::Compatibility.from_properties(properties)
    expect(message).to be_a(Sumac::Messages::Compatibility)
    expect(message.protocol_version).to eq('1')
  end

end
