require 'sumac'

# make sure it exists
describe Sumac::Messenger do

  def build_messenger
    connection = instance_double('Sumac::Connection')
    messenger = Sumac::Messenger.new(connection)
  end

  # ::new
  example do
    connection = instance_double('Sumac::Connection')
    messenger = Sumac::Messenger.new(connection)
    expect(messenger.instance_variable_get(:@connection)).to be(connection)
    expect(messenger.instance_variable_get(:@ongoing)).to be(true)
    expect(messenger).to be_a(Sumac::Messenger)
  end

  # #close
  example do
    messenger = build_messenger
    connection = messenger.instance_variable_get(:@connection)
    message_broker = double
    expect(connection).to receive(:message_broker).with(no_args).and_return(message_broker)
    expect(message_broker).to receive(:close).with(no_args)
    messenger.close
  end

  # #closed
  example do
    messenger = build_messenger
    messenger.instance_variable_set(:@ongoing, true)
    messenger.closed
    expect(messenger.instance_variable_get(:@ongoing)).to be(false)
  end

  # #closed?
  example do
    messenger = build_messenger
    expect(messenger.closed?).to be(messenger.instance_variable_get(:@ongoing))
  end

  # #kill
  example do
    messenger = build_messenger
    connection = messenger.instance_variable_get(:@connection)
    message_broker = double
    expect(connection).to receive(:message_broker).with(no_args).and_return(message_broker)
    expect(message_broker).to receive(:kill).with(no_args)
    messenger.kill
  end

  # #send
  example do
    messenger = build_messenger
    message = instance_double('Sumac::Messages::CallRequest')
    message_string = double
    expect(message).to receive(:to_json).and_return(message_string)
    connection = messenger.instance_variable_get(:@connection)
    message_broker = double
    expect(connection).to receive(:message_broker).with(no_args).and_return(message_broker)
    expect(message_broker).to receive(:send).with(message_string)
    messenger.send(message)
  end

  # #setup

  example do
    messenger = build_messenger
    connection = messenger.instance_variable_get(:@connection)
    message_broker = double
    expect(connection).to receive(:message_broker).with(no_args).and_return(message_broker)
    object_request_broker = double
    expect(connection).to receive(:object_request_broker).with(no_args).and_return(object_request_broker)
    expect(message_broker).to receive(:object_request_broker=).with(object_request_broker)
    messenger.setup
  end

  # #validate_message_broker

  # missing #close
  example do
    messenger = build_messenger
    connection = messenger.instance_variable_get(:@connection)
    message_broker = instance_double('Object')
    expect(connection).to receive(:message_broker).with(no_args).and_return(message_broker)
    expect(message_broker).to receive(:respond_to?).with(:close).and_return(false)
    expect{ messenger.validate_message_broker }.to raise_error(TypeError, /#close/)
  end

  # missing #kill
  example do
    messenger = build_messenger
    connection = messenger.instance_variable_get(:@connection)
    message_broker = instance_double('Object')
    expect(connection).to receive(:message_broker).with(no_args).and_return(message_broker)
    expect(message_broker).to receive(:respond_to?).with(:close).and_return(true)
    expect(message_broker).to receive(:respond_to?).with(:kill).and_return(false)
    expect{ messenger.validate_message_broker }.to raise_error(TypeError, /#kill/)
  end

  # missing #object_request_broker=
  example do
    messenger = build_messenger
    connection = messenger.instance_variable_get(:@connection)
    message_broker = instance_double('Object')
    expect(connection).to receive(:message_broker).with(no_args).and_return(message_broker)
    expect(message_broker).to receive(:respond_to?).with(:close).and_return(true)
    expect(message_broker).to receive(:respond_to?).with(:kill).and_return(true)
    expect(message_broker).to receive(:respond_to?).with(:object_request_broker=).and_return(false)
    expect{ messenger.validate_message_broker }.to raise_error(TypeError, /#object_request_broker=/)
  end

  # missing #send
  example do
    messenger = build_messenger
    connection = messenger.instance_variable_get(:@connection)
    message_broker = instance_double('Object')
    expect(connection).to receive(:message_broker).with(no_args).and_return(message_broker)
    expect(message_broker).to receive(:respond_to?).with(:close).and_return(true)
    expect(message_broker).to receive(:respond_to?).with(:kill).and_return(true)
    expect(message_broker).to receive(:respond_to?).with(:object_request_broker=).and_return(true)
    expect(message_broker).to receive(:respond_to?).with(:send).and_return(false)
    expect{ messenger.validate_message_broker }.to raise_error(TypeError, /#send/)
  end

  # valid
  example do
    messenger = build_messenger
    connection = messenger.instance_variable_get(:@connection)
    message_broker = instance_double('Object')
    expect(connection).to receive(:message_broker).with(no_args).and_return(message_broker)
    expect(message_broker).to receive(:respond_to?).with(:close).and_return(true)
    expect(message_broker).to receive(:respond_to?).with(:kill).and_return(true)
    expect(message_broker).to receive(:respond_to?).with(:object_request_broker=).and_return(true)
    expect(message_broker).to receive(:respond_to?).with(:send).and_return(true)
    messenger.validate_message_broker
  end

end
