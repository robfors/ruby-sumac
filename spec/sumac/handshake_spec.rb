require 'sumac'

# make sure it exists
describe Sumac::Handshake do

  def build_handshake
    connection = instance_double('Sumac::Connection')
    handshake = Sumac::Handshake.new(connection)
  end

  # ::new
  example do
    connection = instance_double('Sumac::Connection')
    handshake = Sumac::Handshake.new(connection)
    expect(handshake.instance_variable_get(:@connection)).to be(connection)
    expect(handshake).to be_a(Sumac::Handshake)
  end

  # #send_compatibility_message
  example do
    handshake = build_handshake
    connection = handshake.instance_variable_get(:@connection)
    message = instance_double('Sumac::Messages::Compatibility')
    expect(Sumac::Messages::Compatibility).to receive(:build).with(protocol_version: '0').and_return(message)
    messenger = instance_double('Sumac::Messenger')
    expect(connection).to receive(:messenger).with(no_args).and_return(messenger)
    expect(messenger).to receive(:send).with(message)
    handshake.send_compatibility_message
  end

  # #send_initialization_message
  example do
    handshake = build_handshake
    connection = handshake.instance_variable_get(:@connection)
    local_entry = double    
    expect(connection).to receive(:local_entry).and_return(local_entry)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    entry_properties = double
    expect(objects).to receive(:convert_object_to_properties).with(local_entry).and_return(entry_properties)
    message = instance_double('Sumac::Messages::Initialization')
    expect(Sumac::Messages::Initialization).to receive(:build).with(entry: entry_properties).and_return(message)
    messenger = instance_double('Sumac::Messenger')
    expect(connection).to receive(:messenger).with(no_args).and_return(messenger)
    expect(messenger).to receive(:send).with(message)
    handshake.send_initialization_message
  end

  # #process_compatibility_message

  # not compatible
  example do
    handshake = build_handshake
    connection = handshake.instance_variable_get(:@connection)
    message = instance_double('Sumac::Messages::Compatibility')
    expect(message).to receive(:protocol_version).with(no_args).and_return('invalid')
    expect{ handshake.process_compatibility_message(message) }.to raise_error(Sumac::ProtocolError)
  end

  # compatible
  example do
    handshake = build_handshake
    message = instance_double('Sumac::Messages::Compatibility')
    expect(message).to receive(:protocol_version).with(no_args).and_return('0')
    handshake.process_compatibility_message(message)
  end

  # #process_initialization_message
  example do
    handshake = build_handshake
    message = instance_double('Sumac::Messages::Initialization')
    entry_properties = double
    expect(message).to receive(:entry).with(no_args).and_return(entry_properties)
    connection = handshake.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    entry = double
    expect(objects).to receive(:convert_properties_to_object).with(entry_properties).and_return(entry)
    remote_entry = instance_double('Sumac::RemoteEntry')
    expect(connection).to receive(:remote_entry).with(no_args).and_return(remote_entry)
    expect(remote_entry).to receive(:set).with(entry)
    handshake.process_initialization_message(message)
  end

  # #validate_local_entry
  
  # valid
  example do
    handshake = build_handshake
    connection = handshake.instance_variable_get(:@connection)  
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    local_entry = double
    expect(connection).to receive(:local_entry).with(no_args).and_return(local_entry)
    expect(objects).to receive(:ensure_sendable).with(local_entry)
    handshake.validate_local_entry
  end

  # not valid
  example do
    handshake = build_handshake
    connection = handshake.instance_variable_get(:@connection)  
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    local_entry = double
    expect(connection).to receive(:local_entry).with(no_args).and_return(local_entry)
    expect(objects).to receive(:ensure_sendable).with(local_entry).and_raise(Sumac::UnexposedObjectError)
    expect{ handshake.validate_local_entry }.to raise_error(Sumac::UnexposedObjectError)
  end

end
