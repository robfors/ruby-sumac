require 'sumac'

# make sure it exists
describe Sumac::Messages::Shutdown do

  # should be a subclass of Message
  example do
    expect(Sumac::Messages::Shutdown < Sumac::Messages::Message).to be(true)
  end

  # ::build, #properties, #to_json

  example do
    message = Sumac::Messages::Shutdown.build
    expect(message).to be_a(Sumac::Messages::Shutdown)
    expect(JSON.parse(message.to_json)).to eq({ 'message_type' => 'shutdown' })
  end

  # ::from_properties

  # unexpected property
  example do
    properties = { 'message_type' => 'shutdown', 'item' => 1 }
    expect{ Sumac::Messages::Shutdown.from_properties(properties) }.to raise_error(Sumac::ProtocolError)
  end

  # all properties present and valid
  example do
    properties = { 'message_type' => 'shutdown' }
    connection = :connection
    message = Sumac::Messages::Shutdown.from_properties(properties)
    expect(message).to be_a(Sumac::Messages::Shutdown)
  end

end
