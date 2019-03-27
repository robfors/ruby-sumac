require 'sumac'

# make sure it exists
describe Sumac::Messages::Initialization do

  # should be a subclass of Message
  example do
    expect(Sumac::Messages::Initialization < Sumac::Messages::Message).to be(true)
  end

  # ::build, #properties, #to_json

  example do
    entry_object = 1
    message = Sumac::Messages::Initialization.build(entry: entry_object)
    expect(message).to be_a(Sumac::Messages::Initialization)
    expect(JSON.parse(message.to_json)).to eq({ 'message_type' => 'initialization', 'entry' => { 'object_type' => 'integer', 'value' => 1 } })
  end

  # ::from_properties

  # missing or unexpected property
  example do
    properties = { 'message_type' => 'initialization' }
    expect{ Sumac::Messages::Initialization.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # all properties present and valid
  example do
    properties = { 'message_type' => 'initialization', 'entry' => { 'object_type' => 'integer', 'value' => 1 } }
    message = Sumac::Messages::Initialization.from_properties(properties)
    expect(message).to be_a(Sumac::Messages::Initialization)
    entry_object = message.entry
    expect(entry_object).to eq(1)
  end

end
