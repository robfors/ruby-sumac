require 'sumac'

# make sure it exists
describe Sumac::ObjectRequestBroker do

  def build_object_request_broker
    entry = double
    message_broker = double
    allow(Sumac::Connection).to receive(:new).and_return(instance_double('Sumac::Connection'))
    allow(Sumac::DirectiveQueue).to receive(:new).and_return(instance_double('Sumac::DirectiveQueue'))
    allow_any_instance_of(Sumac::ObjectRequestBroker).to receive(:initiate)
    object_request_broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    allow_any_instance_of(Sumac::ObjectRequestBroker).to receive(:initiate).and_call_original
    object_request_broker
  end

  # ::new
  example do
    entry = double
    message_broker = double
    connection = instance_double('Sumac::Connection')
    allow(Sumac::Connection).to receive(:new).and_return(connection)
    directive_queue = instance_double('Sumac::DirectiveQueue')
    allow(Sumac::DirectiveQueue).to receive(:new).and_return(directive_queue)
    expect_any_instance_of(Sumac::ObjectRequestBroker).to receive(:initiate).with(no_args)
    object_request_broker = Sumac::ObjectRequestBroker.new(entry: entry, message_broker: message_broker)
    expect(Sumac::Connection).to have_received(:new).with(local_entry: entry, message_broker: message_broker, object_request_broker: object_request_broker)
    expect(Sumac::DirectiveQueue).to have_received(:new).with(no_args)
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to be(directive_queue)
    expect(object_request_broker).to be_a(Sumac::ObjectRequestBroker)
  end

  # #call
  example do
    object_request_broker = build_object_request_broker
    request = double
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    future = instance_double('QuackConcurrency::Future')
    expect(connection).to receive(:request_call).with(request).and_return(future)
    expect(future).to receive(:get).with(no_args)
    object_request_broker.call(request)
  end

  # #close
  example do
    object_request_broker = build_object_request_broker
    connection = object_request_broker.instance_variable_get(:@connection)
    closer = instance_double('Sumac::Closer')
    expect(connection).to receive(:closer).with(no_args).and_return(closer)
    expect(closer).to receive(:wait_until_enabled).with(no_args)
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    expect(connection).to receive(:close).with(no_args)
    expect(object_request_broker).to receive(:join).with(no_args)
    object_request_broker.close
  end

  # #closed?
  example do
    object_request_broker = build_object_request_broker
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    closer = instance_double('Sumac::Closer')
    expect(connection).to receive(:closer).with(no_args).and_return(closer)
    expect(closer).to receive(:closed?).with(no_args).and_return(false)
    expect(object_request_broker.closed?).to be(false)
  end

  # #entry
  example do
    object_request_broker = build_object_request_broker
    connection = object_request_broker.instance_variable_get(:@connection)
    remote_entry = instance_double('Sumac::RemoteEntry')
    expect(connection).to receive(:remote_entry).with(no_args).and_return(remote_entry)
    remote_entry_object = double
    expect(remote_entry).to receive(:get).with(no_args).and_return(remote_entry_object)
    expect(object_request_broker.entry).to be(remote_entry_object)
  end

  # #forget
  
  # no future
  example do
    object_request_broker = build_object_request_broker
    object = double
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    expect(connection).to receive(:forget).with(object).and_return(nil)
    object_request_broker.forget(object)
  end

  # future
  example do
    object_request_broker = build_object_request_broker
    object = double
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    future = instance_double('QuackConcurrency::Future')
    expect(connection).to receive(:forget).with(object).and_return(future)
    expect(future).to receive(:get).with(no_args)
    object_request_broker.forget(object)
  end

  # #join
  example do
    object_request_broker = build_object_request_broker
    connection = object_request_broker.instance_variable_get(:@connection)
    closer = instance_double('Sumac::Closer')
    expect(connection).to receive(:closer).with(no_args).and_return(closer)
    expect(closer).to receive(:join).with(no_args)
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    object_request_broker.join
  end

  # #kill
  example do
    object_request_broker = build_object_request_broker
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute_next).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    expect(connection).to receive(:kill).with(no_args)
    object_request_broker.kill
  end

  # #killed?
  example do
    object_request_broker = build_object_request_broker
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    closer = instance_double('Sumac::Closer')
    expect(connection).to receive(:closer).with(no_args).and_return(closer)
    expect(closer).to receive(:killed?).with(no_args).and_return(false)
    expect(object_request_broker.killed?).to be(false)
  end

  # #message_broker
  example do
    object_request_broker = build_object_request_broker
    connection = object_request_broker.instance_variable_get(:@connection)
    message_broker = double
    expect(connection).to receive(:message_broker).with(no_args).and_return(message_broker)
    expect(object_request_broker.message_broker).to be(message_broker)
  end

  # #messenger_closed
  example do
    object_request_broker = build_object_request_broker
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    expect(connection).to receive(:messenger_closed).with(no_args)
    object_request_broker.messenger_closed
  end

  # #messenger_killed
  example do
    object_request_broker = build_object_request_broker
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    expect(connection).to receive(:messenger_killed).with(no_args)
    object_request_broker.messenger_killed
  end

  # #messenger_received_message
  example do
    object_request_broker = build_object_request_broker
    message_string = double
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    expect(connection).to receive(:messenger_received_message).with(message_string)
    object_request_broker.messenger_received_message(message_string)
  end

  # #receivable?
  example do
    object_request_broker = build_object_request_broker
    object = double
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:receivable?).with(object).and_return(false)
    expect(object_request_broker.receivable?(object)).to be(false)
  end

  # #respond
  example do
    object_request_broker = build_object_request_broker
    call = double
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    expect(connection).to receive(:respond_to_call).with(call)
    object_request_broker.respond(call)
  end

  # #sendable?
  example do
    object_request_broker = build_object_request_broker
    object = double
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:sendable?).with(object).and_return(false)
    expect(object_request_broker.sendable?(object)).to be(false)
  end

  # #stale?
  example do
    object_request_broker = build_object_request_broker
    object = double
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    objects = instance_double('Sumac::Objects')
    expect(connection).to receive(:objects).with(no_args).and_return(objects)
    expect(objects).to receive(:stale?).with(object).and_return(false)
    expect(object_request_broker.stale?(object)).to be(false)
  end

  # #validate_request
  example do
    object_request_broker = build_object_request_broker
    call = double
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    expect(connection).to receive(:validate_request).with(call)
    object_request_broker.validate_request(call)
  end

  # #initiate
  example do
    object_request_broker = build_object_request_broker
    expect(object_request_broker.instance_variable_get(:@directive_queue)).to receive(:execute).with(no_args).and_yield
    connection = object_request_broker.instance_variable_get(:@connection)
    expect(connection).to receive(:initiate).with(no_args)
    object_request_broker.initiate
  end

end
