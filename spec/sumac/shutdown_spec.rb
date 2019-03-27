require 'sumac'

# make sure it exists
describe Sumac::Shutdown do

  # ::new
  example do
    connection = instance_double('Sumac::Connection')
    shutdown = Sumac::Shutdown.new(connection)
    expect(shutdown.instance_variable_get(:@connection)).to be(connection)
    expect(shutdown).to be_a(Sumac::Shutdown)
  end

  # #send_message
  example do
    connection = instance_double('Sumac::Connection')
    shutdown = Sumac::Shutdown.new(connection)
    message = instance_double('Sumac::Messages::Shutdown')
    expect(Sumac::Messages::Shutdown).to receive(:build).with(no_args).and_return(message)
    messenger = instance_double('Sumac::Messenger')
    expect(connection).to receive(:messenger).with(no_args).and_return(messenger)
    expect(messenger).to receive(:send).with(message)
    shutdown.send_message
  end

end
